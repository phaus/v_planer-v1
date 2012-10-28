class ServiceItemsController < UserSpecificController
  before_filter :setup_class_context

  # GET /service_items
  # GET /service_items.xml
  def index
    if params[:start] and params[:end]
      @service_items = @class_context.all :conditions => ['from_date > ? OR to_date < ?', params[:begin], params[:end] ]
    else
      @service_items = @class_context.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @service_items }
      format.json { render :json => @service_items }
    end
  end

  # GET /service_items/1
  # GET /service_items/1.xml
  def show
    @service_item = @class_context.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf  { render :text => @service_item.to_pdf }
      format.xml  { render :xml  => @service_item }
      format.json { render :json => @service_item }
    end
  end

  # GET /service_items/new
  # GET /service_items/new.xml
  def new
    @service_item = @class_context.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @service_item }
      format.json { render :json => @service_item }
    end
  end

  # DELETE /service_items/1
  # DELETE /service_items/1.xml
  def destroy
    @service_item = @class_context.find(params[:id])
    @service_item.destroy

    respond_to do |format|
      format.html { redirect_to(service_items_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  protected
  def setup_class_context
    if params[:selling_id]
      @class_context = Selling.find(params[:selling_id]).service_items
    elsif params[:rental_id]
      @class_context = Rental.find(params[:rental_id]).service_items
    else
      @class_context = ServiceItem
    end
  end

end
