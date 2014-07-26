class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:email].downcase) 
      # With form_tag, we don't generate a hash inside a hash, so don't need 
      # to have the email hash within a sessions hash
      # (I think because we just send down session path without creating a form_for[:session] with that additional session hash)
    if user && user.authenticate(params[:password]) 
      # checks that user exists and can be authenticated through the secure_passwords method
      sign_in user # Note: We have to write "sign_in" function ourselves
      redirect_to user # How does Rails know this represents a web page?
    else
      flash.now[:error] = 'Wrong email and password'
        # flash.now works for rendered pages, vanishes when users go elsewhere
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
