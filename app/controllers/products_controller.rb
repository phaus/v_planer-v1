class ProductsController < UserSpecificController

  is_searchable

  before_filter :load_class_context

  # GET /products
  # GET /products.xml
  def index
    if params[:q].blank?
      if @category
        @products = @class_context
      else
        @products = []
      end
    else
      @products = @class_context.matching(params[:q])
    end

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'list'
        else
          render
        end
      end
      format.xml  { render :xml  => @products }
      format.json { render :json => @products }
    end
  end

  # this action is usually only called via AJAX in the process form
  def search
    if params[:from_date].blank? or params[:to_date].blank?
      @from_date = Date.today
      @to_date   = 1.year.from_now
    else
      @from_date = Date.parse params[:from_date]
      @to_date   = Date.parse params[:to_date]
    end
    case params[:t]
    when 'rentable'
      scope = Product #.s_rentable
    when 'sellable'
      scope = Product #.s_sellable
    when 'service'
      scope = Product #.s_service
    when 'device'
      scope = Product #.s_device
    when 'expense'
      scope = Product #.s_expense
    else
      scope = Product
    end

    @products = scope.for_company(current_company).matching params[:q]

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.xml  { render :xml  => @products }
      format.json { render :json => @products }
    end
  end

  def rentable
    @class_context = @class_context #.s_rentable
    index
  end

  def sellable
    @class_context = @class_context #.s_sellable
    index
  end

  def service
    @class_context = @class_context #.s_service
    index
  end

  def device
    @class_context = @class_context #.s_device
    index
  end

  def expense
    @class_context = @class_context #.s_expense
    index
  end

  # GET /products/1
  # GET /products/1.xml
  def show
    @device = @service = @product = current_company.products.find(params[:id])

    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'details'
        else
          render :action => 'show'
        end
      end
      format.xml  { render :xml  => @product }
      format.json { render :json => @product }
    end
  end

  # GET /products/new
  # GET /products/new.xml
  def new
    if params[:device]
      article = Device.new params[:device]
      @device = article
    elsif params[:service]
      article = Service.new params[:service]
      @service = article
    elsif params[:expense]
      article = Expense.new params[:expense]
      @expense = article
    else
      raise 'No such article type'
    end
    @product = Product.new :article => article
    @product.buying_prices.build unless @expense

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @product }
    end
  end

  # GET /products/1/edit
  def edit
    @expense = @service = @device = @product = current_company.products.find(params[:id])
    @product.buying_prices.build unless @product.buying_prices.count > 0
    if request.xhr?
      render :partial => 'form'
    else
      render :action => 'edit'
    end
  end

  # POST /products
  # POST /products.xml
  def create
    sanitize_category_ids!(params[:product])
    if params[:product][:device]
      article = Device.new params[:product].delete(:device)
      @device = article
    elsif params[:product][:service]
      article = Service.new params[:product].delete(:service)
      @service = article
    elsif params[:product][:expense]
      article = Expense.new params[:product].delete(:expense)
      @expense = article
    else
      raise 'No such article type'
    end
    @product = Product.new params[:product].merge(:article => article)
    @product.company_section = current_user.company_section

    respond_to do |format|
      if @product.save
        flash[:notice] = 'Neues Produkt wurde erstellt'
        format.html { redirect_to(@product) }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.xml
  def update
    sanitize_category_ids!(params[:product])
    @product = current_company.products.find(params[:id], :readonly => false)
    if params[:product][:device]
      article_attributes = params[:product].delete(:device)
    elsif params[:product][:service]
      article_attributes = params[:product].delete(:service)
    elsif params[:product][:expense]
      article_attributes = params[:product].delete(:expense)
    else
      raise 'No such article type'
    end

    successfully_saved = Product.transaction do
      @product.update_attributes! params[:product]
      @product.article.update_attributes! article_attributes
    end

    respond_to do |format|
      if successfully_saved
        flash[:notice] = 'Product was successfully updated.'
        format.html { redirect_to(@product) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.xml
  def destroy
    @product = @class_context.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to(products_url) }
      format.xml  { head :ok }
    end
  end

  protected
  def load_class_context
    if params[:category_id].blank?
      @class_context = current_company.products
    else
      @category      = current_company.categories.find(params[:category_id])
      @class_context = @category.products
    end
  end

  def sanitize_category_ids!(params_hash)
    if params_hash[:category_ids].is_a? Hash
      ids = params_hash.delete(:category_ids)
      params_hash[:category_ids] = ids.map {|id, selected| [true, 1, '1'].include?(selected) ? id : nil }.compact
    end
  end

end
