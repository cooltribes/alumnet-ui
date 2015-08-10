class PaymentwallController < ApplicationController
  skip_before_action :authenticate!
  #layout "public"

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
    #render :text => @pingback.getParameter('payment_type')
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
      elsif(@pingback.getParameter('payment_type') == 'subscription') #membership
        if(@pingback.getParameter('type') == '0') #assign membership
          if(@pingback.getParameter('goodsid') == '222')
            @lifetime = true
            @member = 3
          else
            @end = DateTime.now + 1.year
          end
        
          subscription = Subscription.new
          @data_text = { :user_id => @user_id, :start_date => DateTime.now, :lifetime => @lifetime, :end_date => @end, :creator_id => @user_id, :reference => @reference }.to_json
          @user_text = { :member => @member }.to_json
          subscription.create(JSON.parse(@data_text), session, JSON.parse(@user_text), @user_id, @auth_token)
          @response = JSON.parse(subscription.response.body)
          @response_user = subscription.response_user

          payment = Payment.new
          @payment_text = { :user_id => @user_id, :paymentable_id => @response['id'], :paymentable_type => "Subscription", :subtotal => @pingback.getParameter('amount'), :iva => 0, :total => @pingback.getParameter('amount'), :reference => @reference, :country_id => @pingback.getParameter('country_id'), :city_id => @pingback.getParameter('city_id'), :address => @pingback.getParameter('address') }.to_json
          payment.create(JSON.parse(@payment_text), session, @auth_token)
          @response_payment = payment.response
          render :text => "OK"
          #render json: @response_payment
        elsif(@pingback.getParameter('type') == '2') #deactivate membership
          payment = Payment.new
          @payment_text = { :status => 2 }.to_json
          payment.update(@reference, JSON.parse(@payment_text), session, @auth_token)
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
