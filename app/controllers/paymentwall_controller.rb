class PaymentwallController < ApplicationController
  skip_before_action :authenticate!
  #layout "public"

  def callback
    require 'paymentwall'
    Paymentwall::Base::setApiType(Paymentwall::Base::API_GOODS)
    Paymentwall::Base::setAppKey(Settings.paymentwall_project_key)
    Paymentwall::Base::setSecretKey('ea9c9cad7ce7d4c6ad745b48f36a9d45')

    @lifetime = false
    @end = nil
    @session = session
    @pingback = Paymentwall::Pingback.new(request.GET, request.remote_ip)
    #render :text => @pingback.getParameter('payment_type')
    @user_id = @pingback.getParameter('uid')
    @reference = @pingback.getParameter('ref')
    @event_id = @pingback.getParameter('event_id')

    #if @pingback.validate()
      if(@pingback.getParameter('payment_type') == 'event')
        payment = EventPayment.new
        @auth_token = @pingback.getParameter('auth_token')
        @data_text = { :user_id => @user_id, :price => @pingback.getParameter('amount'), :event_id => @pingback.getParameter('event_id'), :attendance_id => @pingback.getParameter('attendance_id'), :reference => @reference }.to_json
        payment.create(JSON.parse(@data_text), session, @event_id, @auth_token)
        @response = payment.response
        render :text => "OK"
      else
        if(@pingback.getParameter('type') == '0')
          if(@pingback.getParameter('goodsid') == '222')
            @lifetime = true
          else
            @end = DateTime.now + 1.year
          end
        end
        subscription = Subscription.new
        @data_text = { :user_id => @user_id, :begin => DateTime.now, :lifetime => @lifetime, :end => @end, :creator_id => @user_id, :reference => @reference }.to_json
        @user_text = { :member => 1 }.to_json
        subscription.create(JSON.parse(@data_text), session, JSON.parse(@user_text), @user_id)
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
