class PaymentwallController < ApplicationController
  skip_before_action :authenticate!

  def callback
    require 'paymentwall'
    require 'digest/md5'
    require 'httparty'
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
          
          if(@pingback.getParameter('slength'))
            @end = DateTime.now + @pingback.getParameter('slength').to_i.months
          else
            @lifetime = true
            @member = 3
          end
        
          user_product = UserProduct.new
          @data_text = { :user_id => @user_id, :start_date => DateTime.now, :lifetime => @lifetime, :end_date => @end, :product_id => @response_product['id'], :transaction_type => 1, :creator_id => @user_id, :reference => @reference, :feature => 'subscription' }.to_json
          @user_text = { :member => @member }.to_json
          user_product.create(JSON.parse(@data_text), session, @user_id, @auth_token)
          user_product.update_user(JSON.parse(@user_text), session, @user_id, @auth_token)

          @response = JSON.parse(user_product.response.body)
          @response_user = JSON.parse(user_product.response_user.body)

          payment = Payment.new
          @payment_text = { :user_id => @user_id, :paymentable_id => @response_product['id'], :paymentable_type => "Product", :subtotal => @pingback.getParameter('amount'), :iva => 0, :total => @pingback.getParameter('amount'), :reference => @reference, :country_id => @pingback.getParameter('country_id'), :city_id => @pingback.getParameter('city_id'), :address => @pingback.getParameter('address'), :user_product_id => @response['id'] }.to_json
          payment.create(JSON.parse(@payment_text), session, @auth_token)
          @response_payment = payment.response

          # create paymentwall invoice
          @invoice_date = Time.now.strftime("%d/%m/%Y")
          @full_name = @response_user['name']
          @first_name = @full_name.split(' ')[0]
          @last_name = @full_name.split(' ')[1]
          @invoice_params = 'contacts[0][email]='+@response_user['email']+'contacts[0][first_name]='+@first_name+'contacts[0][last_name]='+@last_name+'currency=EURdate='+@invoice_date+'due_date='+@invoice_date+'invoice_number=A-'+@response_payment['id'].to_s+'items[0][currency]=EURitems[0][quantity]=1items[0][title]='+@response['product']['name']+'items[0][unit_cost]='+@response['product']['total_price'].to_s+'key='+Settings.paymentwall_project_key+'sign_version=221ea499b579ed1fdae9fefd7b9fb3446'
          @invoice_sign = Digest::MD5.hexdigest(@invoice_params)
          @invoice_json = { 
                 "key" => Settings.paymentwall_project_key, 
                 "sign_version" => '2', 
                 "sign" => @invoice_sign, 
                 "invoice_number" => 'A-'+@response_payment['id'].to_s, 
                 "currency" => 'EUR',
                 "date" => @invoice_date,
                 "due_date" => @invoice_date,
                 "contacts[0][email]" => @response_user['email'],
                 "contacts[0][first_name]" => @first_name,
                 "contacts[0][last_name]" => @last_name,
                 "items[0][quantity]" => 1,
                 "items[0][unit_cost]" => @response['product']['total_price'].to_s,
                 "items[0][currency]" => 'EUR',
                 "items[0][title]" => @response['product']['name']
               }

          @invoice_result = HTTParty.post('https://api.paymentwall.com/developers/invoice-api/invoice', :body => @invoice_json)

          render :text => "OK"
          #render :text => @pingback.getParameter('slength')
          
          #render json: @response_product.to_json
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
      elsif @pingback.getParameter('payment_type') == 'donation'
        #paymentwall.save_donation(@pingback, @auth_token, @user_id, @reference, @session)
        product = Product.new
        @response_product = product.get(@pingback.getParameter('goodsid'), @auth_token)
        
        if(@pingback.getParameter('amount').to_f < 1000)
          @end = DateTime.now + 12.months
        else
          @lifetime = true
          @member = 3
        end
      
        user_product = UserProduct.new
        @data_text = { 
          :user_id => @user_id, 
          :start_date => DateTime.now, 
          :lifetime => @lifetime, 
          :end_date => @end, 
          :product_id => @response_product['id'], 
          :transaction_type => 1, 
          :creator_id => @user_id, 
          :reference => @reference, 
          :feature => 'donation'
        }.to_json
        @user_text = { :member => @member }.to_json
        user_product.create(JSON.parse(@data_text), session, @user_id, @auth_token)
        user_product.update_user(JSON.parse(@user_text), session, @user_id, @auth_token)

        @response = JSON.parse(user_product.response.body)
        @response_user = JSON.parse(user_product.response_user.body)

        payment = Payment.new
        @payment_text = { 
          :user_id => @user_id, 
          :paymentable_id => @response_product['id'], 
          :paymentable_type => "Product", 
          :subtotal => @pingback.getParameter('amount'), 
          :iva => 0, 
          :total => @pingback.getParameter('amount'), 
          :reference => @reference, 
          :country_id => @pingback.getParameter('country_id'), 
          :city_id => @pingback.getParameter('city_id'), 
          :address => @pingback.getParameter('address'), 
          :user_product_id => @response['id'] 
        }.to_json
        payment.create(JSON.parse(@payment_text), session, @auth_token)
        @response_payment = payment.response

        # create paymentwall invoice
        @invoice_date = Time.now.strftime("%d/%m/%Y")
        @full_name = @response_user['name']
        @first_name = @full_name.split(' ')[0]
        @last_name = @full_name.split(' ')[1]
        @invoice_params = 'contacts[0][email]='+@response_user['email']+'contacts[0][first_name]='+@first_name+'contacts[0][last_name]='+@last_name+'currency=EURdate='+@invoice_date+'due_date='+@invoice_date+'invoice_number=A-'+@response_payment['id'].to_s+'items[0][currency]=EURitems[0][quantity]=1items[0][title]='+@response['product']['name']+'items[0][unit_cost]='+@response['product']['total_price'].to_s+'key='+Settings.paymentwall_project_key+'sign_version=221ea499b579ed1fdae9fefd7b9fb3446'
        @invoice_sign = Digest::MD5.hexdigest(@invoice_params)
        @invoice_json = { 
               "key" => Settings.paymentwall_project_key, 
               "sign_version" => '2', 
               "sign" => @invoice_sign, 
               "invoice_number" => 'A-'+@response_payment['id'].to_s, 
               "currency" => 'EUR',
               "date" => @invoice_date,
               "due_date" => @invoice_date,
               "contacts[0][email]" => @response_user['email'],
               "contacts[0][first_name]" => @first_name,
               "contacts[0][last_name]" => @last_name,
               "items[0][quantity]" => 1,
               "items[0][unit_cost]" => @response['product']['total_price'].to_s,
               "items[0][currency]" => 'EUR',
               "items[0][title]" => @response['product']['name']
             }

        @invoice_result = HTTParty.post('https://api.paymentwall.com/developers/invoice-api/invoice', :body => @invoice_json)

        render :text => "OK"
        #render :text => @pingback.getParameter('slength')
        
        #render json: @response_product.to_json
      end
    else
      @response = @pingback.getErrorSummary()
      puts @pingback.getErrorSummary()
    end
  end
end
