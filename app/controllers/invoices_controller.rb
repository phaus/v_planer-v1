class InvoicesController < ApplicationController
  # GET /invoices
  # GET /invoices.xml
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
    @invoices = current_company.invoices.all :order => 'invoice_no DESC', :conditions => ['date BETWEEN ? AND ?', @from_date, @to_date]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  def open
    @invoices = Invoice.find_by_sql <<-EOSQL
      SELECT invoices.* FROM invoices JOIN
        (SELECT id as process_id, 'Selling' AS process_type, workflow_state FROM `sellings`
        UNION
        SELECT id as process_id, 'Rental' AS process_type, workflow_state FROM `rentals`) AS processes
      ON processes.process_id=invoices.process_id AND processes.process_type=invoices.process_type
      WHERE workflow_state='billed'
      AND invoices.company_id=#{current_company.id}
    EOSQL

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  # GET /invoices/1
  # GET /invoices/1.xml
  def show
    if params[:rental_id]
      @invoice = current_company.rentals.find(params[:rental_id]).invoice
    elsif params[:selling_id]
      @invoice = current_company.sellings.find(params[:selling_id]).invoice
    else
      @invoice = current_company.invoices.find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @invoice }
      format.json { render :json => @invoice }
      format.pdf  { send_data @invoice.to_pdf, :type => Mime::PDF, :disposition => "inline" }
    end
  end

  # GET /invoices/new
  # GET /invoices/new.xml
  def new
    if not params[:rental_id].blank?
      @process = current_company.rentals.find params[:rental_id]
    elsif not params[:selling_id].blank?
      @process = current_company.sellings.find params[:selling_id]
    end
    @invoice = @process.prepare_invoice

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invoice }
    end
  end

  # GET /invoices/1/edit
  def edit
    @invoice = current_company.invoices.find(params[:id])
  end

  # POST /invoices
  # POST /invoices.xml
  def create
    case params[:invoice][:process_type]
    when 'Rental'
      @process = current_company.rentals.find params[:invoice][:process_id]
    when 'Selling'
      @process = current_company.sellings.find params[:invoice][:process_id]
    else
      raise 'WTF?!'
    end
    @invoice = @process.create_invoice!(params[:invoice])

    respond_to do |format|
      if @invoice.save
        flash[:notice] = 'Invoice was successfully created.'
        format.html { redirect_to(@invoice) }
        format.xml  { render :xml => @invoice, :status => :created, :location => @invoice }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invoices/1
  # PUT /invoices/1.xml
  def update
    @invoice = current_company.invoices.find(params[:id])

    respond_to do |format|
      if @invoice.update_attributes(params[:invoice])
        flash[:notice] = 'Invoice was successfully updated.'
        format.html { redirect_to(@invoice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.xml
  def destroy
    @invoice = current_company.invoices.find(params[:id])
    @invoice.destroy

    respond_to do |format|
      format.html { redirect_to(invoices_url) }
      format.xml  { head :ok }
    end
  end
end
