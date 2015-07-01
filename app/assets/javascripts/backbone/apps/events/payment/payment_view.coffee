@AlumNet.module 'EventsApp.Payment', (Payment, @AlumNet, Backbone, Marionette, $, _) ->

  class Payment.PaymentView extends Marionette.ItemView
    template: 'events/payment/templates/payment'
    className: 'row'

    initialize: (options)->
      @current_user = options.current_user
      @model = options.model

    ui:
      'selectPaymentCountries': '#js-payment-countries'
      'divCountry': '#country'
      'paymentwallContent': '#paymentwall-content'

    events:
      'change #js-payment-countries': 'reloadWidget'

    templateHelpers: ->
      current_user: @current_user
      model: @model
      name: @model.get('name')

    reloadWidget: (e)->
      country = new AlumNet.Entities.Country
        id: e.val
      view = this
      price = view.model.get("regular_price")
      paymentwall_return_url = window.location.origin
      paymentwall_project_key = AlumNet.paymentwall_project_key
      country.fetch
        success: (model) ->
          parameters_string = 'ag_external_id=order_no_555123ag_name='+view.model.get("name")+'ag_type=fixedamount='+price+'attendance_id='+attendance_id+'auth_token='+auth_token+'country_code='+model.get('cc_fips')+'currencyCode=USDevent_id='+view.model.get("id")+'key='+paymentwall_project_key+'payment_type=eventsign_version=2success_url='+paymentwall_return_url+'uid='+view.current_user.get("id")+'widget=p1_1ea9c9cad7ce7d4c6ad745b48f36a9d45'
          #view.ui.divCountry.html('Country set to: '+model.get('cc_fips')+'</br>String: '+parameters_string+'</br></br>Sign calculated: '+CryptoJS.MD5(parameters_string).toString())
          view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription?key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&uid='+view.current_user.get("id")+'&country_code='+model.get('cc_fips')+'&widget=p1_1&amount='+price+'&currencyCode=USD&ag_name='+view.model.get("name")+'&ag_external_id=order_no_555123&ag_type=fixed&sign_version=2&payment_type=event&event_id='+view.model.get("id")+'&attendance_id='+attendance_id+'&auth_token='+auth_token+'&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>')
          #view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription?key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&uid='+view.current_user.get("id")+'&widget=p1_1&amount='+price+'&currencyCode=USD&ag_name='+view.model.get("name")+'&ag_external_id=order_no_555123&ag_type=fixed&sign_version=2&payment_type=event&event_id='+view.model.get("id")+'&attendance_id='+attendance_id+'&auth_token='+auth_token+'&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="318" frameborder="0"></iframe>')
          #view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription/?key=1acce8f2587d6f7cca456c87cc672bd2&widget=p1_1&success_url=http://alumnet-test.aiesec-alumni.org&uid='+view.current_user.get("id")+'&country_code='+model.get('cc_fips')+'&sign_version=2&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="318" frameborder="0"></iframe>')
      this.render()
      
    onRender: ->
      view = this
      price = view.model.get("regular_price")
      auth_token = AlumNet.current_token
      attendance_id = view.model.get('attendance_info').id
      #paymentwall_return_url = encodeURI(window.location.href)
      #paymentwall_return_url = "http://localhost:3000/%23events/10/payment"
      #paymentwall_return_url = paymentwall_return_url.replace("#", "%23")
      #console.log paymentwall_return_url
      paymentwall_return_url = window.location.origin
      # if(AlumNet.environment == "development")
      #   paymentwall_return_url = 'http://alumnet-test.aiesec-alumni.org/'+window.location.hash+'/'

      paymentwall_project_key = AlumNet.paymentwall_project_key
      if(view.current_user.is_premium)
        price = view.model.get("premium_price")
      #parameters_string = 'ag_external_id=order_no_555123ag_name='+view.model.get("name")+'ag_type=fixedamount='+price+'attendance_id='+attendance_id+'auth_token='+auth_token+'currencyCode=USDevent_id='+view.model.get("id")+'key=1acce8f2587d6f7cca456c87cc672bd2payment_type=eventsign_version=2success_url=http://alumnet-test.aiesec-alumni.orguid='+view.current_user.get("id")+'widget=p1_1ea9c9cad7ce7d4c6ad745b48f36a9d45'
      parameters_string = 'ag_external_id=order_no_555123ag_name='+view.model.get("name")+'ag_type=fixedamount='+price+'attendance_id='+attendance_id+'auth_token='+auth_token+'currencyCode=USDevent_id='+view.model.get("id")+'key='+paymentwall_project_key+'payment_type=eventsign_version=2success_url='+paymentwall_return_url+'uid='+view.current_user.get("id")+'widget=p1_1ea9c9cad7ce7d4c6ad745b48f36a9d45'
      #view.ui.divCountry.html('String: '+parameters_string+'</br></br>Sign calculated: '+CryptoJS.MD5(parameters_string).toString())
      #view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription?key=1acce8f2587d6f7cca456c87cc672bd2&success_url=http://localhost:3000/#events/7/payment&uid='+view.current_user.get("id")+'&widget=p1_1&amount='+price+'&currencyCode=USD&ag_name='+view.model.get("name")+'&ag_external_id=order_no_555123&ag_type=fixed&sign_version=2&payment_type=event&event_id='+view.model.get("id")+'&attendance_id='+attendance_id+'&auth_token='+auth_token+'&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="318" frameborder="0"></iframe>')
      view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription?key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&uid='+view.current_user.get("id")+'&widget=p1_1&amount='+price+'&currencyCode=USD&ag_name='+view.model.get("name")+'&ag_external_id=order_no_555123&ag_type=fixed&sign_version=2&payment_type=event&event_id='+view.model.get("id")+'&attendance_id='+attendance_id+'&auth_token='+auth_token+'&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>')

      data = CountryList.toSelect2()

      @ui.selectPaymentCountries.select2
        placeholder: "Select a Country"
        data: data

  class Payment.ReceiptView extends Marionette.ItemView
    template: 'events/payment/templates/receipt'
    className: 'row'

    initialize: (options)->
      @current_user = options.current_user
      @model = options.model

    templateHelpers: ->
      current_user: @current_user
      model: @model
      name: @model.get('name')