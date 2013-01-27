class DistributorsController < ApplicationController

  is_searchable

  # GET /distributors
  # GET /distributors.xml
  def index
    @distributors = current_company.distributors.all
    unless params[:q].blank?
      @distributors = @distributors.reject do |client|
        !(client.company_name.to_s.downcase.include?(params[:q].downcase) or
          client.contact_person.to_s.downcase.include?(params[:q].downcase))
      end
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'list'
        else
          render :action => 'index'
        end
      end
      format.xml  { render :xml => @distributors }
    end
  end

  # GET /distributors/1
  # GET /distributors/1.xml
  def show
    @distributor = current_company.distributors.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @distributor }
    end
  end

  # GET /distributors/new
  # GET /distributors/new.xml
  def new
    @distributor = current_company.distributors.new
    @distributor.build_address
    @distributor.build_bank_account

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @distributor }
    end
  end

  # GET /distributors/1/edit
  def edit
    @distributor = current_company.distributors.find(params[:id])
    @distributor.address      ||= Address.new
    @distributor.bank_account ||= BankAccount.new
  end

  # POST /distributors
  # POST /distributors.xml
  def create
    @distributor = Distributor.new(params[:distributor])
    @distributor.company = current_company

    respond_to do |format|
      if @distributor.save
        flash[:notice] = 'Distributor was successfully created.'
        format.html { redirect_to(@distributor) }
        format.xml  { render :xml => @distributor, :status => :created, :location => @distributor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @distributor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /distributors/1
  # PUT /distributors/1.xml
  def update
    @distributor = current_company.distributors.find(params[:id])
    respond_to do |format|
      if @distributor.update_attributes(params[:distributor])
        flash[:notice] = 'Distributor was successfully updated.'
        format.html { redirect_to(@distributor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @distributor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /distributors/1
  # DELETE /distributors/1.xml
  def destroy
    @distributor = current_company.distributors.find(params[:id])
    @distributor.destroy

    respond_to do |format|
      format.html { redirect_to(distributors_url) }
      format.xml  { head :ok }
    end
  end
end
