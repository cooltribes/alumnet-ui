@AlumNet.module 'PaymentApp.Checkout', (Checkout, @AlumNet, Backbone, Marionette, $, _) ->

  class Checkout.PaymentView extends Marionette.ItemView
    template: 'payment/checkout/templates/payments'
    className: 'col-md-8 col-md-offset-3'

    initialize: (options)->
      document.title = 'AlumNet - Become a member'
      @current_user = options.current_user
      @condition = options.condition
      console.log options.data
      @data = options.data

    ui:
      'selectPaymentCountries': '#js-payment-countries'
      'selectPaymentCities': '#js-payment-cities'
      'divCountry': '#country'
      'paymentwallContent': '#paymentwall-content'

    events:
      'change #js-payment-countries': 'loadCities'
      'click button.js-submit': 'submitClicked'

    templateHelpers: ->
      current_user: @current_user
      condition: @condition

    optionsForSelectCities: (url)->
      placeholder: "Select a City"
      minimumInputLength: 2
      ajax:
        url: url
        dataType: 'json'
        data: (term)->
          q:
            name_cont: term
        results: (data, page) ->
          results:
            data
      formatResult: (data)->
        data.name
      formatSelection: (data)->
        data.name

    loadCities: (e)->
      url = AlumNet.api_endpoint + '/countries/' + e.val + '/cities'
      @$("#js-payment-cities").select2(@optionsForSelectCities(url))

    onRender: ->
      data = CountryList.toSelect2()
      @ui.selectPaymentCountries.select2
        placeholder: "Select a Country"
        data: data

      @ui.selectPaymentCities.select2
        placeholder: "Select a City"
        data: []

    submitClicked: (e)->
      e.preventDefault()
      #subscriptions = AlumNet.request('product:entities')
      view = this
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      valid_address = true
      profile = view.current_user.profile
      address = {}
      _.forEach data, (value, key, list)->
        if value == '' then valid_address = false
      
      
      if valid_address
        country = new AlumNet.Entities.Country
          id: data.country_id
        
        country.fetch
          success: (model) ->
            console.log @data
            paymentwall_project_key = AlumNet.paymentwall_project_key
            paymentwall_secret_key = AlumNet.paymentwall_secret_key
            console.log "return url: " + window.location.origin
            paymentwall_return_url = window.location.origin
            auth_token = AlumNet.current_token
            
            profile = view.current_user.profile
            birthday = profile.get('born')
            birthday_object = new Date(birthday.year, birthday.month-1, birthday.day)

            parameters_string = 'address='+data.address+'auth_token='+auth_token+'city_id='+data.city_id+'country_code='+model.get('cc_fips')+'country_id='+data.country_id+'customer[address]='+data.address+'customer[birthday]='+birthday_object.getTime()+'customer[country]='+model.get('name')+'customer[firstname]='+profile.get('first_name')+'customer[lastname]='+profile.get('last_name')+'email='+view.current_user.get("email")
            content_html = '<iframe src="https://api.paymentwall.com/api/cart/?address='+data.address+'&auth_token='+auth_token+'&city_id='+data.city_id+'&country_code='+model.get('cc_fips')+'&country_id='+data.country_id+'&customer[address]='+data.address+'&customer[birthday]='+birthday_object.getTime()+'&customer[country]='+model.get('name')+'&customer[firstname]='+profile.get('first_name')+'&customer[lastname]='+profile.get('last_name')+'&email='+view.current_user.get("email")

            subscriptions = AlumNet.request('product:entities', {q: { feature_eq: 'subscription' }})
            #subscriptions.on 'fetch:success', (collection)->
            #  subscriptions.each (subscription, index)->
            #    console.log subscription
            #    console.log index
            #    parameters_string += 'external_ids['+index+']='+subscription.get('sku')
            #    content_html += '&external_ids['+index+']='+subscription.get('sku')

            #  parameters_string +='key='+paymentwall_project_key+'sign_version=2success_url='+paymentwall_return_url+'uid='+view.current_user.get("id")+'widget=p1_1'+paymentwall_secret_key
            #  console.log parameters_string
            #  content_html += '&key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&uid='+view.current_user.get("id")+'&widget=p1_1'+'&sign_version=2&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>'
            #  console.log content_html
            #  console.log view.ui.paymentwallContent
            #  console.log $('#paymentwall-content').html()
            #  view.ui.paymentwallContent.html(content_html)
            

                

            #parameters_string = 'address='+data.address+'auth_token='+auth_token+'city_id='+data.city_id+'country_code='+model.get('cc_fips')+'country_id='+data.country_id+'customer[address]='+data.address+'customer[birthday]='+birthday_object.getTime()+'customer[country]='+model.get('name')+'customer[firstname]='+profile.get('first_name')+'customer[lastname]='+profile.get('last_name')+'email='+view.current_user.get("email")+'key='+paymentwall_project_key+'sign_version=2success_url='+paymentwall_return_url+'uid='+view.current_user.get("id")+'widget=p1_1'+paymentwall_secret_key
            #content_html = '<iframe src="https://api.paymentwall.com/api/cart/?key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&widget=p1_1&uid='+view.current_user.get("id")+'&email='+view.current_user.get("email")+'&customer[firstname]='+profile.get('first_name')+'&customer[lastname]='+profile.get('last_name')+'&customer[birthday]='+birthday_object.getTime()+'&customer[address]='+data.address+'&customer[country]='+model.get('name')+'&country_code='+model.get('cc_fips')+'&country_id='+data.country_id+'&city_id='+data.city_id+'&address='+data.address+'&auth_token='+auth_token+'&sign_version=2&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>'
            

            
      else
        $.growl.error({ message: "Please fill address fields" })