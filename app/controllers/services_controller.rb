class ServicesController < UserSpecificController

  # GET /services/new
  def new
    redirect_to new_product_path(:service => {:name => 'Neue Dienstleistung'})
  end

end
