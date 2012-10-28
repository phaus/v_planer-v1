class DevicesController < UserSpecificController

  before_filter :load_class_context,
      :only => [:availability, :available]

  # GET /devices/new
  def new
    redirect_to new_product_path(:device => {:name => 'Neuer Artikel'})
  end

  protected

  def load_class_context
    if params[:category_id].blank?
      @class_context = current_company.products.rentable
    else
      @category      = current_company.categories.find params[:category_id]
      @class_context = @category.devices.rentable
    end
  end

#   def handle_csv_upload
#     if params[:csv_file].is_a? ActionController::UploadedStringIO
#       Tempfile.open('uploaded_csv') do |f|
#         f << params[:csv_file].read
#         f.close
#         DeviceCsvImporter.import! f.path
#       end
#     else
#       DeviceCsvImporter.import! params[:csv_file].path
#       File.unlink params[:csv_file].path rescue nil
#     end
#
#     respond_to do |format|
#       format.html { redirect_to devices_path }
#       format.any  { head :ok, :location => devices_path }
#     end
#   end
end
