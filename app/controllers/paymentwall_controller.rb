class PaymentwallController < ApplicationController
  layout "public"

  def callback
    require 'paymentwall'
    Paymentwall::Base::setApiType(Paymentwall::Base::API_GOODS)
    Paymentwall::Base::setAppKey('1acce8f2587d6f7cca456c87cc672bd2')
    Paymentwall::Base::setSecretKey('ea9c9cad7ce7d4c6ad745b48f36a9d45')

    @lifetime = false
    @end = nil
    @session = session
    @pingback = Paymentwall::Pingback.new(request.GET, request.remote_ip)
    if(@pingback.getParameter('type') == '0')
      if(@pingback.getParameter('goodsid') == 'Lifetime')
        @lifetime = true
      else
        @end = DateTime.now + 1.year
      end
    end
    subscription = Subscription.new
    @data_text = { :user_id => session[:user_id], :begin => DateTime.now, :lifetime => @lifetime, :end => @end, :creator_id => session[:user_id] }.to_json
    @response = subscription.create(JSON.parse(@data_text), session)
    
    if @pingback.validate()
      productId = @pingback.getProduct().getId()
      if @pingback.isDeliverable()
        subscription = Subscription.new()
        subscription.create(1)
      elsif @pingback.isCancelable()
        # withdraw the product
      end 
      puts 'OK' # Paymentwall expects response to be OK, otherwise the @pingback will be resent
    else
      puts @pingback.getErrorSummary()
    end
  end
end