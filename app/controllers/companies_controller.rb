class CompaniesController < UserSpecificController
  requires_company_admin_for :all,
      :except => [:show]

  def show
    @user = current_user
    @company = current_company
    respond_to do |format|
      format.html do
        if request.xhr?
          render :partial => 'details'
        else
          redirect_to account_path
        end
      end
      format.xml  { render :xml  => @company }
      format.json { render :json => @company }
    end
  end

  def edit
    @company = current_company
    @company.main_section.bank_account ||= BankAccount.new
    @company.main_section.address      ||= Address.new
    if request.xhr?
      render :partial => 'edit'
    else
      render :action => 'edit'
    end
  end

  def update
    @user    = current_user
    @company = current_company
    respond_to do |format|
      if @company.update_attributes(params[:company])
        format.html do
          if request.xhr?
            if params[:come_from] == 'bank_details'
              render :partial => 'bank_account/details'
            else
              render :partial => 'details'
            end
          else
            redirect_to :action => 'show'
          end
        end
        format.any  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml  => @user.errors.full_messages, :status => :unprocessable_entity }
        format.json { render :json => @user.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

end
