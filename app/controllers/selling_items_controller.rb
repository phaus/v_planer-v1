require 'vpim/icalendar'

class SellingItemsController < UserSpecificController
  before_filter :setup_class_context

  # GET /selling_items
  # GET /selling_items.xml
  def index
    if params[:start] and params[:end]
      @selling_items = @class_context.all :conditions => ['from_date > ? OR to_date < ?', params[:begin], params[:end] ]
    else
      @selling_items = @class_context.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @selling_items }
      format.json { render :json => @selling_items }
    end
  end

  # GET /selling_items/1
  # GET /selling_items/1.xml
  def show
    @selling_item = @class_context.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf  { render :text => @selling_item.to_pdf }
      format.xml  { render :xml  => @selling_item }
      format.json { render :json => @selling_item }
    end
  end

  # GET /selling_items/new
  # GET /selling_items/new.xml
  def new
    @selling_item = @class_context.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @selling_item }
      format.json { render :json => @selling_item}
    end
  end

  # DELETE /selling_items/1
  # DELETE /selling_items/1.xml
  def destroy
    @selling_item = @class_context.find(params[:id])
    @selling_item.destroy

    respond_to do |format|
      format.html { redirect_to(selling_items_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  protected
  def setup_class_context
    if params[:device_id]
      @class_context = Device.find(params[:device_id]).selling_items
    elsif params[:selling_id]
      @class_context = Selling.find(params[:selling_id]).device_items
    else
      @class_context = SellingItem
    end
  end

end
