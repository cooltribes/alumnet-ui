class PaymentwallController < ApplicationController
  skip_before_action :authenticate!

  def callback
    require 'paymentwall'
    Paymentwall::Base::setApiType(Paymentwall::Base::API_GOODS)
    Paymentwall::Base::setAppKey(Settings.paymentwall_project_key)
    Paymentwall::Base::setSecretKey(Settings.paymentwall_secret_key)

    @lifetime = false
    @end = nil
    @member = 1
    @session = session
    @pingback = Paymentwall::Pingback.new(request.GET, request.remote_ip)
    @auth_token = @pingback.getParameter('auth_token')
    @user_id = @pingback.getParameter('uid')
    @reference = @pingback.getParameter('ref')
    @event_id = @pingback.getParameter('event_id')

    if @pingback.validate()
      if(@pingback.getParameter('payment_type') == 'event')
         payment = Payment.new
         @payment_text = { :user_id => @user_id, :paymentable_id => @pingback.getParameter('event_id'), :paymentable_type => "Event", :subtotal => @pingback.getParameter('amount'), :iva => 0, :total => @pingback.getParameter('amount'), :reference => @reference, :country_id => @pingback.getParameter('country_id'), :city_id => @pingback.getParameter('city_id'), :address => @pingback.getParameter('address') }.to_json
         #@data_text = { :user_id => @user_id, :price => @pingback.getParameter('amount'), :event_id => @pingback.getParameter('event_id'), :attendance_id => @pingback.getParameter('attendance_id'), :reference => @reference }.to_json
         payment.create(JSON.parse(@payment_text), session, @auth_token)
         @response = payment.response
         #render json: @response
         render :text => "OK"
      #else
      elsif(@pingback.getParameter('payment_type') == 'subscription') #membership
        if(@pingback.getParameter('type') == '0') #assign membership
          product = Product.new
          @response_product = product.get(@pingback.getParameter('goodsid'), @auth_token)
          if(@response_product['quantity'])
            @end = DateTime.now + @response_product['quantity'].months
          else
            @lifetime = true
            @member = 3
          end
        
          user_product = UserProduct.new
          @data_text = { :user_id => @user_id, :start_date => DateTime.now, :lifetime => @lifetime, :end_date => @end, :product_id => @response_product['id'], :transaction_type => 1, :creator_id => @user_id, :reference => @reference }.to_json
          @user_text = { :member => @member }.to_json
          user_product.create(JSON.parse(@data_text), session, @user_id, @auth_token)
          user_product.update_user(JSON.parse(@user_text), session, @user_id, @auth_token)

          @response = JSON.parse(user_product.response.body)
          @response_user = user_product.response_user

          payment = Payment.new
          @payment_text = { :user_id => @user_id, :paymentable_id => @response_product['id'], :paymentable_type => "Subscription", :subtotal => @pingback.getParameter('amount'), :iva => 0, :total => @pingback.getParameter('amount'), :reference => @reference, :country_id => @pingback.getParameter('country_id'), :city_id => @pingback.getParameter('city_id'), :address => @pingback.getParameter('address') }.to_json
          payment.create(JSON.parse(@payment_text), session, @auth_token)
          @response_payment = payment.response
          #render :text => "OK"
          #render :text => @response_product['quantity']
          render json: @response_user
        elsif(@pingback.getParameter('type') == '2') #deactivate membership
          payment = Payment.new
          @payment_text = { :status => 2 }.to_json
          payment.update(@reference, JSON.parse(@payment_text), session, @auth_token)
          @response_payment = payment.response
          render :text => "OK"
          #render json: @response
        end
      elsif @pingback.getParameter('payment_type') == 'job_post'
        if(@pingback.getParameter('type') == '0') #assign job posts
          product = Product.new
          @response_product = product.get(@pingback.getParameter('goodsid'), @auth_token)

          user_product = UserProduct.new
          # transaction_type
          # 1: add job posts
          # 2: use job post
          @data_text = { :user_id => @user_id, :start_date => DateTime.now, :quantity => @response_product['quantity'], :product_id => @response_product['id'], :transaction_type => 1, :creator_id => @user_id, :reference => @reference }.to_json
          user_product.create(JSON.parse(@data_text), session, @user_id, @auth_token)
          @response = JSON.parse(user_product.response.body)

          payment = Payment.new
          @payment_text = { :user_id => @user_id, :paymentable_id => @response_product['id'], :paymentable_type => "Product", :subtotal => @pingback.getParameter('amount'), :iva => 0, :total => @pingback.getParameter('amount'), :reference => @reference, :country_id => @pingback.getParameter('country_id'), :city_id => @pingback.getParameter('city_id'), :address => @pingback.getParameter('address') }.to_json
          payment.create(JSON.parse(@payment_text), session, @auth_token)
          @response_payment = payment.response
          render :text => "OK"
          #render json: @response_payment
        end
      end
    else
      @response = @pingback.getErrorSummary()
      puts @pingback.getErrorSummary()
    end
  end
end
