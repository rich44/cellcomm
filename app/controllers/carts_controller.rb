class CartsController < ApplicationController

  before_action :logged_in?, :only => [:cart, :create_cart]
  before_action :user
  before_action :highest_id, :only => [:cart_process, :order_submit]

  def calculate_totals
    phones_array = []
    if @user.cart.cart_items.present?
      @user.cart.cart_items.each do |item|
        phone_total = item.phone.price * item.quantity_sold
        phones_array << phone_total
      end
      @subtotal = phones_array.inject{|memo,n| memo + n}
      @tax_total = @subtotal * 0.13
      @total = @subtotal + @tax_total
    end
  end

  def cart
    calculate_totals
  end


  def cart_process
    params_hash = params.slice(*[*"1"..highest_id])
    params_hash.each do |k,v|
      cart_item = @user.cart.cart_items.where(:phone_id => k).first
      cart_item.update_attributes(:phone_id => k, :quantity_sold => v,
        :cart => @user.cart)
    end
    redirect_to(checkout_path)
  end

  def checkout
    @address = @user.address || @user.create_address
    calculate_totals
  end

  def create_cart
    @phone = Phone.find(params[:phone_id])

    return if @phone.quantity == 0
      user_items = @user.cart.cart_items
      found_item = user_items.find{|x| x.phone_id == params[:phone_id].to_i}

      if found_item
        found_item.update_attributes(:quantity_sold => params[:quantity])
      else
        #change instance variables to local variables
        new_item = CartItem.new(:phone_id => params[:phone_id],
          :quantity_sold => params[:quantity], :cart => @user.cart)
        user_items << new_item
        new_item.save
      end # if
      redirect_to(cart_page_path)
  end # create_cart

  def order_submit
    delivery_date = Time.now + 7.days

    begin
      order_number = (0..8).map{[*0..9, *"A".."Z"].sample}.join
    end until Order.where(order_number: order_number).none?

    order = Order.create(:delivery_date => delivery_date, :order_number =>
      order_number, :user_id => @user)
    #grab only values you need from subhashes
    params_hash = params.slice(*[*"1"..highest_id])

    params_hash.each do |k,v|
      order_item = OrderItem.create(:phone_id => k, :quantity_sold => v,
        :order => order)
    end
    order.update_attributes(:delivery_date => delivery_date, :order_number =>
      order_number, :user_id => session[:user_id])
    @user.cart.cart_items.destroy_all
    redirect_to(user_page_path)
  end


  def remove_item
    #local variable / instance variable change
    cart_items = @user.cart.cart_items.where(:phone_id => params[:phone_id])
    cart_items.destroy_all
    calculate_totals
  end

  def update_address
    @address = @user.address || @user.create_address
    if @address.update_attributes(address_params)
      calculate_totals
      flash.now[:notice] = "Address successfully saved"
    else
      respond_to do |format|
        format.js { render :partial => "address_only.js.erb" }
      end
    end
  end

  def update_price
     params_hash = params.slice("phone-quantity")
     params_hash.each do |k,v|
       cart_items = @user.cart.cart_items
       found_item = cart_items.find_by(:phone_id => v[0])
       found_item.update_attributes(:quantity_sold => v[1])
     end
     calculate_totals
     render :partial => "cart_info.html.erb", :layout => false
  end

  private

  def address_params
    params.require(:address).permit(:address, :postal_code, :province, :country,
    :city)
  end

  def highest_id
    Phone.pluck(:id).max.to_s
  end
end
