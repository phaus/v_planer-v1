class CommercialProcessesController < ApplicationController

  before_filter :handle_client_search

  # GET /commercial_processes
  # GET /commercial_processes.xml
  def index
    @commercial_processes = current_user.company_section.commercial_processes

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @commercial_processes }
      format.json { render :json => @commercial_processes }
    end
  end

  # GET /commercial_processes/1
  # GET /commercial_processes/1.xml
  def show
    @commercial_process = current_company.commercial_processes.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @commercial_process }
    end
  end

  # GET /commercial_processes/new
  # GET /commercial_processes/new.xml
  def new
    @commercial_process = current_company.commercial_processes.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @commercial_process }
      format.json { render :json => @commercial_process }
    end
  end

  # GET /commercial_processes/1/edit
  def edit
    @commercial_process = current_company.commercial_processes.find(params[:id])
  end

  # POST /commercial_processes
  # POST /commercial_processes.xml
  def create
    @commercial_process = current_company.commercial_processes.new(params[:commercial_process])
    @commercial_process.init! :as => current_user

    respond_to do |format|
      if @commercial_process.halted?
        format.html { render :action => 'new' }
        format.xml  { render :xml  => @commercial_process.errors, :status => :unprocessable_entity }
        format.json { render :json => @commercial_process.errors, :status => :unprocessable_entity }
      else
        flash[:notice] = 'CommercialProcess was successfully created.'
        format.html { redirect_to commercial_process_path(@commercial_process) }
        format.xml  { render :xml  => @commercial_process, :status => :created, :location => commercial_process_path(@commercial_process) }
        format.json { render :json => @commercial_process, :status => :created, :location => commercial_process_path(@commercial_process) }
      end
    end
  end

  # PUT /commercial_processes/1
  # PUT /commercial_processes/1.xml
  def update
    @commercial_process = current_company.commercial_processes.find(params[:id])

    @commercial_process.as_user current_user do
      @commercial_process.update_attributes(params[:commercial_process])
    end

    respond_to do |format|
      if not @clients.nil? or @commercial_process.halted?
        format.html { render :action => 'edit' }
        format.xml  { render :xml  => @commercial_process.errors, :status => :unprocessable_entity }
        format.json { render :json => @commercial_process.errors, :status => :unprocessable_entity }
      else
        flash[:notice] = 'CommercialProcess was successfully updated.'
        format.html { redirect_to edit_commercial_process_path(@commercial_process) }
        format.xml  { head :ok }
        format.json { head :ok }
      end
    end
  end

  # DELETE /commercial_processes/1
  # DELETE /commercial_processes/1.xml
  def destroy
    @commercial_process = current_company.commercial_processes.find(params[:id])
    @commercial_process.destroy

    respond_to do |format|
      format.html { redirect_to(commercial_processes_url) }
      format.xml  { head :no_content }
      format.json { head :no_content }
    end
  end

  protected

  def handle_client_search
    if params[:cq].present? and params[:commit] == 'search-client'
      @clients = current_company.clients.matching(params[:cq])
    end
  end
end
