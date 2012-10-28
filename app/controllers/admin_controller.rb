class AdminController < ApplicationController
  requires_admin_for :all

  def show
  end

end
