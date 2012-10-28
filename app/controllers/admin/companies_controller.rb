class Admin::CompaniesController < ApplicationController
  include AdminHelper

  # GET /admin/companies
  # GET /admin/companies.xml
  def index
    @companies = Company.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @companies }
    end
  end

  # GET /admin/companies/1
  # GET /admin/companies/1.xml
  def show
    @company = Company.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company }
    end
  end

  # GET /admin/companies/new
  # GET /admin/companies/new.xml
  def new
    @company = Company.new :admin => User.new, :main_section => CompanySection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @company }
    end
  end

  # GET /admin/companies/1/edit
  def edit
    @company = Company.find(params[:id])
    @company.main_section ||= CompanySection.new
  end

  # POST /admin/companies
  # POST /admin/companies.xml
  def create
    @company = Company.new(params[:company])
    @company.admin.company_section = @company.main_section
    @company.main_section.name     = @company.name

    respond_to do |format|
      if @company.save
        flash[:notice] = 'Company was successfully created.'
        format.html { redirect_to([:admin, @company]) }
        format.xml  { render :xml => @company, :status => :created, :location => [:admin, @company] }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/companies/1
  # PUT /admin/companies/1.xml
  def update
#     raise params[:company].inspect
    @company = Company.find(params[:id])

    respond_to do |format|
      if @company.update_attributes(params[:company])
        flash[:notice] = 'Company was successfully updated.'
        format.html { redirect_to([:admin, @company]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/companies/1
  # DELETE /admin/companies/1.xml
  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    respond_to do |format|
      format.html { redirect_to(admin_companies_path) }
      format.xml  { head :ok }
    end
  end
end
