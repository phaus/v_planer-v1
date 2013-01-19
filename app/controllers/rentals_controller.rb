class RentalsController < UserSpecificController

  skip_before_filter :require_user, :only => :index
  before_filter :login_via_token, :only => :index

  before_filter :assure_not_billed,
      :only => [:edit, :update, :delete]

  before_filter :search_clients,
      :only => [:new, :create, :edit, :update]

  include ApplicationHelper

  # GET /rentals
  # GET /rentals.xml
  # GET /rentals.json
  # GET /rentals.ics
  def index
    if params[:from_date].blank?
      @from_date = Date.today.at_beginning_of_month
    else
      @from_date = Date.parse(params[:from_date]).at_beginning_of_month
    end

    if params[:to_date].blank?
      @to_date = @from_date.at_end_of_month
    else
      @to_date = Date.parse(params[:to_date]).at_end_of_month
    end
    @rentals = current_company.rentals.all :order => 'begin ASC', :conditions => ['begin < ? AND end > ?', @to_date, @from_date]

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'list'
        end
      end
      format.xml  { render :xml  => @rentals }
      format.json { render :json => @rentals }
      format.ics
    end
  end

  def open
    @rentals = current_company.rentals.all :limit => '0,500',
        :order      => 'created_at DESC',
        :conditions => %q(workflow_state NOT IN ('rejected', 'billed', 'closed', 'payed'))

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'list'
        end
      end
      format.xml  { render :xml  => @rentals }
      format.json { render :json => @rentals }
      format.ics
    end
  end

  # GET /rentals/1
  # GET /rentals/1.xml
  def show
    @process = @rental = current_company.rentals.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.pdf  { send_data @rental.to_pdf, :type => Mime::PDF, :disposition => 'inline' }
      format.xml  { render :xml  => @rental.to_xml(:include => :items) }
      format.json { render :json => @rental.to_json(:include => :items) }
    end
  end

  # GET /rentals/1/offer.pdf
  def offer
    @process = @rental = current_company.rentals.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf  { send_data @rental.to_pdf_offer, :type => Mime::PDF, :disposition => 'inline' }
    end
  end

  # GET /rentals/1/packing_note.pdf
  def packing_note
    @process = @rental = current_company.rentals.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf  { send_data @rental.to_pdf_packing_note, :type => Mime::PDF, :disposition => 'inline' }
    end
  end

  # GET /rentals/1/offer_confirmation.pdf
  def offer_confirmation
    @rental = @selling = current_company.rentals.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf  { render :text => @rental.to_pdf_offer_confirmation }
    end
  end

  # GET /rentals/new
  # GET /rentals/new.xml
  def new
    @rental = Rental.new params[:rental]
    @rental.sender = current_user.company_section

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rental }
    end
  end

  # GET /rentals/1/edit
  def edit
    @process = @rental = current_company.rentals.find(params[:id])
  end

  # POST /rentals
  # POST /rentals.xml
  def create
    params[:rental].delete(:user_id)
    # begin HACK -- this shall be removed
    sanitize_decimal_input!(params[:rental])
    sanitize_new_product_input!(params[:process]||{})
    # end HACK

    @rental = Rental.new params[:rental]
    @rental.select_client!(:as => current_user)

    respond_to do |format|
      if @rental.halted? or not @rental.save
        flash[:notice] = t(@rental.halted_because, :scope => 'workflow.halted_because.rental')
        format.html { render :action => 'new' }
        format.xml  { render :xml => @rental.errors, :status => :unprocessable_entity }
      else
        flash[:notice] = t('controller.rentals.created')
        format.html { redirect_to @rental }
        format.xml  { render :xml => @rental, :status => :created, :location => @rental }
      end
    end
  end

  # PUT /rentals/1/remarks
  # GET /rentals/1/remarks
  def remarks
    @rental = current_company.rentals.find(params[:id])
    if request.put?
      @rental.update_attribute :remarks, params[:rental][:remarks]
    end
    respond_to do |format|
      format.xml  { render :xml  => @rental.remarks }
      format.json { render :json => @rental.remarks }
      format.any  { render :text => @rental.remarks }
    end
  end

  # PUT /rentals/1
  # PUT /rentals/1.xml
  def update
    @rental = current_company.rentals.find(params[:id])
    if params[:rental]
      params[:rental].delete(:user_id)
      sanitize_decimal_input!(params[:rental])
      sanitize_new_product_input!(params[:process] || {})
      workflow_action = params[:rental].delete(:action)
      workflow_action = nil unless %w(accept reject close create_invoice receive_payment remove_invoice).include?(workflow_action.to_s)
    end

    attrs = HashWithIndifferentAccess.new
    attrs.merge! params[:rental]  if params[:rental]
    attrs.merge! params[:process] if params[:process]

    success = Rental.transaction do
      @rental.update_attributes!(attrs) if attrs.keys.any?
      @rental.send "#{workflow_action}!" if workflow_action
      true
    end

    respond_to do |format|
      if success
        flash[:notice] = 'Der Vorgang wurde aktualisiert.'
        format.html { redirect_to(@rental) }
        format.xml  { head :ok }
      else
        flash[:notice] = "Fehler: #{@rental.errors.full_messages.join(', ')}"
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @rental.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rentals/1
  # DELETE /rentals/1.xml
  def destroy
    @rental = current_company.rentals.find(params[:id])
    @rental.destroy

    respond_to do |format|
      format.html { redirect_to(rentals_url) }
      format.xml  { head :ok }
    end
  end

  private

  def sanitize_decimal_input!(rental_attributes)
    [:discount, :client_discount, :usage_duration, :billed_duration].each do |k|
      rental_attributes[k] = decimalize(rental_attributes[k]) if rental_attributes[k]
    end
    rental_attributes
  end

  def decimalize(str)
    str.sub(',', '.').to_f
  end

  def login_via_token
    if params[:format] == 'html'
      return require_user
    else
      @current_user = User.where(:single_access_token => params[:t]).first || current_user
      if @current_user.nil?
        return require_user
      end
    end
    true
  end

  def assure_not_billed
    if @rental and @rental.billed?
      flash[:error] = 'Dieser Vorgang wurde bereits abgerechnet und kann daher nicht mehr verändert werden.'
      redirect_to(@rental) and return false
    end
    true
  end

  def sanitize_new_product_input!(rental_attributes)
    attrs = rental_attributes.delete(:new_device_items_attributes) || []
    rental_attributes[:new_device_items_attributes] = []
    attrs.each do |item|
      if item[:product_attributes].nil?
        rental_attributes[:new_device_items_attributes] << item
      else
        next if item[:product_attributes][:device_attributes].nil?
        next if item[:product_attributes][:device_attributes][:available_count].to_i == 0
        item[:product_attributes][:device_attributes][:rental_price] ||= item[:unit_price]
        item[:product_attributes][:company_section_id] = current_user.company_section_id
        rental_attributes[:new_items_attributes] << item
      end
    end
  end

  def search_clients
    if params[:cq].blank?
      # use selected user id
    elsif not params[:cq].blank?
      clients = Client.matching(params[:cq]).all
      case clients.count
      when 0
        flash[:notice] = t('controller.rentals.no clients found')
      else
        @clients = clients
      end
    end
  end

end
