class SellingsController < UserSpecificController

  skip_before_filter :require_user,
      :only => :index
  before_filter :login_via_token,
      :only => :index

  before_filter :assure_not_billed,
      :only => [:edit, :update, :delete]

  # GET /sellings
  # GET /sellings.xml
  # GET /sellings.json
  # GET /sellings.ics
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
    @sellings = current_company.sellings.all :limit => '0,500', :order => 'created_at DESC', :conditions => ['created_at BETWEEN ? AND ?', @from_date, @to_date]
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'list'
        end
      end
      format.xml  { render :xml  => @sellings }
      format.json { render :json => @sellings }
      format.doc_html
    end
  end

  def open
    respond_to do |format|
      @sellings = current_company.sellings.all :limit => '0,500', :order => 'created_at DESC', :conditions => %q(workflow_state NOT IN ('rejected', 'billed', 'closed', 'payed'))
      format.html
      format.xml  { render :xml  => @sellings }
      format.json { render :json => @sellings }
      format.doc_html
    end
  end

  # GET /sellings/1
  # GET /sellings/1.xml
  def show
    @process = @selling = current_company.sellings.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.pdf  { render :text => @selling.to_pdf }
      format.xml  { render :xml  => @selling.to_xml(:include => [:device_items, :service_items]) }
      format.json { render :json => @selling.to_json(:include => [:device_items, :service_items]) }
    end
  end

  # GET /sellings/1/offer
  # GET /sellings/1/offer.pdf
  def offer
    @process = @selling = current_company.sellings.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf  { render :text => @selling.to_pdf_offer }
    end
  end

  # GET /sellings/1/packing_note.pdf
  def packing_note
    @process = @selling = current_company.sellings.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf  { render :text => @selling.to_pdf_packing_note }
    end
  end

  # GET /sellings/1/offer_confirmation.pdf
  def offer_confirmation
    @process = @selling = current_company.sellings.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf  { render :text => @selling.to_pdf_offer_confirmation }
    end
  end

  # GET /sellings/new
  # GET /sellings/new.xml
  def new
    @process = @selling = Selling.new(params[:selling])
    @selling.sender = current_user.company_section

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @selling }
    end
  end

  # GET /sellings/1/edit
  def edit
    @process = @selling = current_company.sellings.find(params[:id])
  end

  # POST /sellings
  # POST /sellings.xml
  def create
    params[:selling].delete(:user_id)

    @selling = current_company.sellings.new params[:selling]
    @selling.sender = current_user.company_section
    @selling.user   = current_user
    @selling.new_device_items_attributes  = (params[:process][:new_device_items_attributes]  || []) + (params[:selling][:new_device_items_attributes]  || [])
    @selling.new_service_items_attributes = (params[:process][:new_service_items_attributes] || []) + (params[:selling][:new_service_items_attributes] || [])

    respond_to do |format|
      if no_item_data?
        format.html { render :action => 'new' }
      elsif @selling.save
        flash[:notice] = 'Selling was successfully created.'
        format.html { redirect_to(@selling) }
        format.xml  { render :xml => @selling, :status => :created, :location => @selling }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @selling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sellings/1
  # PUT /sellings/1.xml
  def update
    @selling = current_company.sellings.find(params[:id])
    if params[:selling]
      params[:selling].delete(:user_id)
#       sanitize_new_product_input!(params[:process]||{})
      workflow_action = params[:selling].delete(:action)
      workflow_action = nil unless %w(accept reject close create_invoice receive_payment remove_invoice).include?(workflow_action.to_s)
    end

    attrs = HashWithIndifferentAccess.new
    attrs.merge! params[:selling] if params[:selling]
    attrs.merge! params[:process] if params[:process]

    success = Rental.transaction do
      @selling.update_attributes!(attrs)  if attrs.keys.any?
      @selling.send "#{workflow_action}!" if workflow_action
      true
    end

    respond_to do |format|
      if success
        flash[:notice] = 'Selling was successfully updated.'
        format.html { redirect_to(@selling) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @selling.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rentals/1/remarks
  # GET /rentals/1/remarks
  def remarks
    @selling = current_company.sellings.find(params[:id])
    if request.put?
      @selling.update_attribute :remarks, params[:selling][:remarks]
    end
    respond_to do |format|
      format.xml  { render :xml  => @selling.remarks }
      format.json { render :json => @selling.remarks }
      format.any  { render :text => @selling.remarks }
    end
  end

  # DELETE /sellings/1
  # DELETE /sellings/1.xml
  def destroy
    @selling = current_company.sellings.find(params[:id])
    @selling.destroy

    respond_to do |format|
      format.html { redirect_to(sellings_url) }
      format.xml  { head :ok }
    end
  end

  private

  def login_via_token
    if params[:format] == 'html'
      return require_user
    else
      @current_user = User.find_by_single_access_token(params[:t]) || current_user
      if @current_user.nil?
        return require_user
      end
    end
    true
  end

  def assure_not_billed
    if @selling and @selling.billed?
      flash[:error] = 'Dieser Vorgang wurde bereits abgerechnet und kann daher nicht mehr verändert werden.'
      redirect_to(@selling) and return false
    end
    true
  end

  def no_item_data?
    params[:selling][:device_items_attributes].nil? and params[:process][:new_device_items_attributes].nil? and
        params[:selling][:service_items_attributes].nil? and params[:process][:new_service_items_attributes].nil?
  end

end
