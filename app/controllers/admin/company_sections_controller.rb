class Admin::CompanySectionsController < ApplicationController
  include AdminHelper

  # GET /admin/company_sections
  # GET /admin/company_sections.xml
  def index
    @company_sections = CompanySection.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @company_sections }
    end
  end

  # GET /admin/company_sections/1
  # GET /admin/company_sections/1.xml
  def show
    @company_section = CompanySection.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company_section }
    end
  end

  # GET /admin/company_sections/new
  # GET /admin/company_sections/new.xml
  def new
    @company_section = CompanySection.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @company_section }
    end
  end

  # GET /admin/company_sections/1/edit
  def edit
    @company_section = CompanySection.find(params[:id])
  end

  # POST /admin/company_sections
  # POST /admin/company_sections.xml
  def create
    @company_section = CompanySection.new(params[:company_section])

    respond_to do |format|
      if @company_section.save
        flash[:notice] = 'CompanySection was successfully created.'
        format.html { redirect_to([:admin, @company_section]) }
        format.xml  { render :xml => @company_section, :status => :created, :location => [:admin, @company_section] }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @company_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/company_sections/1
  # PUT /admin/company_sections/1.xml
  def update
    @company_section = CompanySection.find(params[:id])

    respond_to do |format|
      if @company_section.update_attributes(params[:company_section])
        flash[:notice] = 'CompanySection was successfully updated.'
        format.html { redirect_to([:admin, @company_section]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @company_section.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/company_sections/1
  # DELETE /admin/company_sections/1.xml
  def destroy
    @company_section = CompanySection.find(params[:id])
    @company_section.destroy

    respond_to do |format|
      format.html { redirect_to(admin_company_sections_path) }
      format.xml  { head :ok }
    end
  end
end
