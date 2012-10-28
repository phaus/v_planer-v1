class UserSessionsController < ApplicationController

  requires_login_for :destroy

  requires_no_login_for :new, :create

  def show
    redirect_to :action => 'new'
  end

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      path = is_admin? ? admin_path : account_url
      redirect_to path
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    redirect_to new_user_session_url
  end

end
