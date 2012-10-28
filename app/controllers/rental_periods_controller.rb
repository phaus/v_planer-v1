require 'vpim/icalendar'

class RentalPeriodsController < UserSpecificController
  before_filter :setup_class_context

  # GET /rental_periods
  # GET /rental_periods.xml
  def index
    if params[:start] and params[:end]
      @rental_periods = @class_context.all :conditions => ['from_date > ? OR to_date < ?', params[:begin], params[:end] ]
    else
      @rental_periods = @class_context.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @rental_periods }
      format.json { render :json => @rental_periods }
    end
  end

  # GET /rental_periods/1
  # GET /rental_periods/1.xml
  def show
    @rental_period = @class_context.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.pdf  { render :text => @rental_period.to_pdf }
      format.xml  { render :xml  => @rental_period }
      format.json { render :json => @rental_period }
    end
  end

  # GET /rental_periods/new
  # GET /rental_periods/new.xml
  def new
    @rental_period = @class_context.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @rental_period }
      format.json { render :json => @rental_period }
    end
  end

  # DELETE /rental_periods/1
  # DELETE /rental_periods/1.xml
  def destroy
    @rental_period = @class_context.find(params[:id])
    @rental_period.destroy

    respond_to do |format|
      format.html { redirect_to(rental_periods_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end

  protected
  def setup_class_context
    if params[:device_id]
      @class_context = Device.find(params[:device_id]).rental_periods
    elsif params[:rental_id]
      @class_context = Rental.find(params[:rental_id]).device_items
    else
      @class_context = RentalPeriod
    end
  end

end
