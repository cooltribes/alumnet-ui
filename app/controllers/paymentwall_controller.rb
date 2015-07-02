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

    #if @pingback.validate()
      if(@pingback.getParameter('payment_type') == 'event')
        payment = EventPayment.new
        @data_text = { :user_id => @user_id, :price => @pingback.getParameter('amount'), :event_id => @pingback.getParameter('event_id'), :attendance_id => @pingback.getParameter('attendance_id'), :reference => @reference }.to_json
        payment.create(JSON.parse(@data_text), session, @event_id, @auth_token)
        @response = payment.response
        render :text => "OK"
      else
        if(@pingback.getParameter('type') == '0')
          if(@pingback.getParameter('goodsid') == '222')
            @lifetime = true
            @member = 3
          else
            @end = DateTime.now + 1.year
          end
        end
        subscription = Subscription.new
        @data_text = { :user_id => @user_id, :start_date => DateTime.now, :lifetime => @lifetime, :end_date => @end, :creator_id => @user_id, :reference => @reference }.to_json
        @user_text = { :member => @member }.to_json
        subscription.create(JSON.parse(@data_text), session, JSON.parse(@user_text), @user_id, @auth_token)
        @response = subscription.response
        @response_user = subscription.response_user

        render :text => "OK"
      end
    #else
      #@response = @pingback.getErrorSummary()
      #puts @pingback.getErrorSummary()
    #end
  end
end
