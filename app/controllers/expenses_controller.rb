class ExpensesController < UserSpecificController

  # GET /expenses/new
  def new
    redirect_to new_product_path(:expense => {:name => 'Neuer Spesenartikel'})
  end

end
