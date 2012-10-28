class AccountController < UserSpecificController
  def show
    @user    = current_user
    @company = current_company
  end

  def edit
    @user    = current_user
    @company = current_company
    @company.main_section.bank_account ||= BankAccount.new
    @company.main_section.address      ||= Address.new
  end

  def update
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to :action => :show }
        format.any  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @user.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

end
