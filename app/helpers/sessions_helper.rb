module SessionsHelper

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
      # Rails utility, treats cookies like hash with value+exp. date
      # .permanent addition keeps cookie alive for 20 years
    user.update_attribute(:remember_token, User.digest(remember_token))
      # Save HASHED token to the database (kept safe until sessions ends)
    self.current_user = user
      # Lets us sign in without the redirect action from "create"
      # In this case, self = session (define user for current session)
  end

  def signed_in?
  !current_user.nil?
      # That is, true if current_user is defined
  end

  def current_user=(user)    
    # Same as self.current_user = user, explicitly handles self-assignment for @current_user storage
    @current_user = user
  end

  # def current_user
  #   @current_user     # Useless! Don't use this line.
  #     #This instance variable would be reset every time we opened a new page
  # end
  
  def current_user
    remember_token = User.digest(cookies[:remember_token])
    # We keep the cookie, so we can use it to track down
    # the user on each new page (HTTP won't save the user)
    @current_user ||= User.find_by(remember_token: remember_token)
      # Only sets @current_user if it is originally undefined/nil
      # (and keeps it at its current value otherwise)
      # So we don't need to find @current_user more than once per user request
      # 
      # Using our permanent session token, we keep resetting ->
      # @current_user as the user whose session is running
  end

  def current_user?(user)
    user == current_user
  end
  # Just checks (through correct_user method) that the user
  # is trying to access their OWN page

  def sign_out
    current_user.update_attribute(:remember_token, 
                                  User.digest(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end
end
