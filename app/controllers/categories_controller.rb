class CategoriesController < UserSpecificController
  # GET /categories
  # GET /categories.xml
  def index
    @categories = current_company.categories.order(:name)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @categories }
      format.json { render :text => @categories.to_json(:include => :products) }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category  = current_company.categories.find(params[:id])
    @from_date = Date.parse(params[:from_date]) rescue 1.week.ago.to_date
    @to_date   = Date.parse(params[:to_date])   rescue (@from_date + 3.weeks).to_date

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @category }
      format.json { render :text => @category.to_json(:include => :products) }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = current_company.categories.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = current_company.categories.find(params[:id])
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])
    @category.company_section = current_user.company_section

    respond_to do |format|
      if @category.save
        flash[:notice] = 'Die Kategorie wurde estellt.'
        format.html { redirect_to(@category) }
        format.xml  { render :xml  => @category, :status => :created, :location => @category }
        format.json { render :text => @category.to_json, :status => :created, :location => @category }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
        format.json { render :text => @category.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = current_company.categories.find(params[:id], :readonly => false)

    respond_to do |format|
      if @category.update_attributes(params[:category])
        flash[:notice] = 'Die Kategorie wurde aktualisiert.'
        format.html { redirect_to(@category) }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
        format.json { render :xml => @category.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    @category = current_company.categories.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
end
