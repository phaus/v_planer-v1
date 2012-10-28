class BankAccountsController < UserSpecificController
  requires_company_admin_for :edit

  def edit
    @company = current_company
    @company.main_section.bank_account ||= BankAccount.new
  end

  def show
    render :partial => 'details'
  end
end
