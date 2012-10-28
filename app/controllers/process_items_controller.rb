class ProcessItemsController < UserSpecificController
  before_filter :setup_class_context

  # GET /rental_periods
  # GET /rental_periods.xml
  def index
    @items = @class_context.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @items }
      format.json { render :text => @items.to_json }
    end
  end


  # GET /rental_periods/1
  # GET /rental_periods/1.xml
  def show
    @item = @class_context.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.pdf  { render :text => @item.to_pdf }
      format.xml  { render :xml  => @item }
      format.json { render :text => @item.to_json }
    end
  end

  protected
  def setup_class_context
    if params[:device_id]
      @class_context = Device.find(params[:device_id]).process_items
    elsif params[:rental_id]
      @class_context = Selling.find(params[:rental_id]).items
    else
      @class_context = SellingItem
    end
  end

end
