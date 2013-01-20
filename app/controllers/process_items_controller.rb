class ProcessItemsController < ApplicationController
  layout 'commercial_processes'

  before_filter :handle_product_search, :only => [:new, :edit]
  before_filter :load_process

  # GET /process_items
  # GET /process_items.xml
  def index
    @process_items = @commercial_process.items.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @process_items }
    end
  end

  # GET /process_items/1
  # GET /process_items/1.xml
  def show
    @process_item = @commercial_process.items.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @process_item }
    end
  end

  # GET /process_items/new
  # GET /process_items/new.xml
  def new
    @process_item = @commercial_process.items.new(params[:process_item])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @process_item }
    end
  end

  # GET /process_items/1/edit
  def edit
    @process_item = @commercial_process.items.find(params[:id])
    @process_item.attributes = params[:process_item]
  end

  # POST /process_items
  # POST /process_items.xml
  def create
    @process_item = @commercial_process.items.new
    @process_item.attributes = params[:process_item]

    respond_to do |format|
      if @process_item.save
        format.html { redirect_to(commercial_process_path(@commercial_process), :notice => 'Process item was successfully created.') }
        format.xml  { render :xml => @process_item, :status => :created, :location => @process_item }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @process_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /process_items/1
  # PUT /process_items/1.xml
  def update
    @process_item = @commercial_process.items.find(params[:id])

    respond_to do |format|
      if @process_item.update_attributes(params[:process_item])
        format.html { redirect_to(commercial_process_path(@commercial_process), :notice => 'Process item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @process_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /process_items/1
  # DELETE /process_items/1.xml
  def destroy
    @process_item = @commercial_process.items.find(params[:id])
    @process_item.destroy

    respond_to do |format|
      format.html { redirect_to(process_items_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def handle_product_search
    if params[:pq].present? and params[:commit] == 'search-product'
      @products = current_company.products.matching(params[:pq])
    end
  end

  def load_process
    @commercial_process = current_company.commercial_processes.find(params[:commercial_process_id])
  end

end
