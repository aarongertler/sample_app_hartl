class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :index, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  # You can create and view users without signing in,
  # but you'll be redirected to sign in otherwise


  def show #note: you actually have to define this one!
    @user = User.find(params[:id])
  end

  def index
    # @users = User.all
    @users = User.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the sample app."
      redirect_to @user   #goes to the show page automagically
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    # So update/1 leads us to user 1, we can cut off access to that
    # page for user 2 later
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end


  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                    :password_confirmation)
      # But not "admin"! We'll keep that one to ourselves...
    end

    # Before filter:

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
      # The notice here is part of a hash on "redirect" = cool shortcut!
      # But we can't do this shortcut with :error or :success...
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
      # So any admin issuing the "admins only" destroy request gets booted
    end
end
