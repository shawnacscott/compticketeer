# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Include all helpers, all the time
  helper :all

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  # Filters
  before_filter :require_user

  # Exception notification, setup in "config/initializers/exception_notification.rb"
  if EXCEPTION_NOTIFICATION_ENABLED
    include ExceptionNotifiable
    local_addresses.clear
  end

  protected

  #==[ Utilities ]==============================================================

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  helper_method :current_user_session

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  helper_method :current_user

  #==[ Filters ]================================================================

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # Set @event variable
  def assign_event
    @event = Event.new
    @event.get_event
  end
end
