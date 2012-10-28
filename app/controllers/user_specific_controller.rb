class UserSpecificController < ApplicationController
  requires_login_for :all

end
