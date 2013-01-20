# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  helper_method :current_user_session, :current_user, :current_company, :is_company_admin?, :is_admin?

  protected

  def self.requires_login_for(*args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    if args.first == :all
      before_filter :require_user, :except => opts[:except]
    else
      before_filter :require_user, :only => args
    end
  end

  def self.requires_no_login_for(*args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    if args.first == :all
      before_filter :require_no_user, :except => opts[:except]
    else
      before_filter :require_no_user, :only => args
    end
  end

  def self.requires_admin_for(*args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    if args.first == :all
      before_filter :require_admin, :except => opts[:except]
    else
      before_filter :require_admin, :only => args
    end
  end

  def self.requires_company_admin_for(*args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    if args.first == :all
      before_filter :require_company_admin, :except => opts[:except]
    else
      before_filter :require_company_admin, :only => args
    end
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = 'Sie müssen eingeloggt sein, um diese Seite aufrufen zu können.'
      redirect_to new_user_session_url
      return false
    end
    true
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = 'Sie müssen ausgeloggt sein, um diese Seite aufrufen zu können.'
      redirect_to account_url
      return false
    end
    true
  end

  def require_admin
    require_user or return false
    unless is_admin?
      store_location
      flash[:notice] = 'Sie benötigen Administratorrechte, um auf diese Seite zugreifen zu dürfen.'
      redirect_to account_path
      return false
    end
    true
  end

  def require_company_admin
    require_user or return false
    unless is_company_admin? or is_admin?
      store_location
      flash[:notice] = 'Nur der Firmen-Administrator darf auf diese Seite zugreifen!'
      redirect_to account_path
      return false
    end
    true
  end

  def store_location
    session[:return_to] = request.url
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def current_user_session
    return @current_user_session if defined? @current_user_session
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined? @current_user
    @current_user = current_user_session && current_user_session.user
  end

  def current_company
    current_user.try :company
  end

  def is_company_admin?
    current_user and current_user.id == current_company.admin.id
  end

  def is_admin?
    # FIXME: replace with some real logic
    current_user and current_user.login == 'wvk'
  end

end
