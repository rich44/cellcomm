class UsersController < ApplicationController
  before_action :user

  def create
    @new_user = User.new(new_user_params)
    if @new_user.save
      cart = Cart.create(:user => @new_user)
      link = view_context.link_to("here.", login_page_path, :class => 'here')
      flash[:notice] = "You have successfully registered. Please login #{link}".html_safe
      redirect_to(phones_path)
    else
      flash.now[:notice] = "You have not successfully registered."
      render("new")
    end
  end

  def new
    @new_user = User.new
  end

  def user_edit
    puts @user.inspect
    @user_edit = UserEdit.new(@user)
    flash.now[:notice] = "Personal information saved." if @user_edit.submit(updated_params)
  end

  def user_page
    puts @user.inspect
    @address =  @user.address || @user.build_address
    @user_edit = UserEdit.new(@user)
    @orders = @user.orders.includes(:order_items)
  end

  private

  def new_user_params
    params.require(:user).permit(:username, :password, :first_name, :last_name,
      :email)
  end

  def updated_params
    params.require(:user_edit).permit(:first_name,
      :last_name, :email, :address, :city, :province,
      :country, :postal_code)
  end

end
