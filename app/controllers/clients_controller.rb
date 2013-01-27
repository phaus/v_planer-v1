class ClientsController < UserSpecificController

  is_searchable

  # GET /clients
  # GET /clients.xml
  def index
    if params[:q].blank?
      @clients = current_company.clients.all  :order => 'client_no'
    else
      @clients = current_company.clients.matching(params[:q]).all  :order => 'client_no'
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'list'
        else
          render :action => 'index'
        end
      end
      format.xml  { render :xml  => @clients }
      format.json { render :text => @clients.to_json }
      format.csv
    end
  end

  # GET /clients/search
  # GET /clients/search.xml
  # GET /clients/search.json
  def search
    if params[:q].blank?
      @clients = current_company.clients.all  :order => 'client_no'
    else
      @clients = current_company.clients.matching(params[:q]).all  :order => 'client_no'
    end
    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.xml  { render :xml  => @clients }
      format.json { render :json => @clients }
    end
  end

  # GET /clients/1
  # GET /clients/1.xml
  def show
    @client = current_company.clients.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @client }
      format.json { render :text => @client.to_json }
    end
  end

  # GET /clients/new
  # GET /clients/new.xml
  def new
    @client = current_company.clients.new :client_no => Client.next_client_no
    @client.address      ||= Address.new
    @client.bank_account ||= BankAccount.new

    respond_to do |format|
      format.html
      format.xml  { render :xml  => @client }
      format.json { render :text => @client.to_json }
    end
  end

  # GET /clients/1/edit
  def edit
    @client = current_company.clients.find(params[:id])
    @client.address      ||= Address.new
    @client.bank_account ||= BankAccount.new
  end

  # POST /clients
  # POST /clients.xml
  def create
    @client = Client.new(params[:client])
    if  is_company_admin?
      @client.contact_person ||= current_user
    else
      @client.contact_person = current_user
    end
    @client.company = current_company

    respond_to do |format|
      if @client.save
        flash[:notice] = 'Client was successfully created.'
        format.html { redirect_to(@client) }
        format.xml  { render :xml  => @client, :status => :created, :location => @client }
        format.json { render :json => @client, :status => :created, :location => @client }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml    => @client.errors, :status => :unprocessable_entity }
        format.json { render :json   => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.xml
  def update
    @client = current_company.clients.find(params[:id])

    respond_to do |format|
      if @client.update_attributes(params[:client])
        flash[:notice] = 'Client was successfully updated.'
        format.html { redirect_to(@client) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml    => @client.errors, :status => :unprocessable_entity }
        format.json { render :text   => @client.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.xml
  def destroy
    @client = current_company.clients.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to(clients_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
