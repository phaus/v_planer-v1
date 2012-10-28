class UsersController < UserSpecificController
  requires_company_admin_for :all

  # GET /users
  # GET /users.xml
  def index
    @users = current_company.users.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = current_company.users.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    @user.build_bank_account
    @user.build_address

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = current_company.users.find(params[:id])
    @user.address      ||= Address.new
    @user.bank_account ||= BankAccount.new
  end

  # POST /users
  # POST /users.xml
  def create
    @user = current_company.users.new(params[:user])
    company_section = CompanySection.find(params[:user][:company_section_id])
    @user.company_section =  company_section if company_section.company == current_company
    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = current_company.users.find(params[:id], :readonly => false)
    if params[:user][:company_section_id]
      company_section = CompanySection.find(params[:user][:company_section_id])
      @user.company_section = company_section if company_section.company == current_company
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = current_company.users.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
