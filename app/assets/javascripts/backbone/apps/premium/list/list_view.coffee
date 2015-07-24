@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'col-md-8 col-md-offset-3'

    initialize: (options)->
      @current_user = options.current_user
      @condition = options.condition

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


    reloadWidget: (e)->
      country = new AlumNet.Entities.Country
        id: e.val
      view = this
      country.fetch
        success: (model) ->
          paymentwall_project_key = AlumNet.paymentwall_project_key
          paymentwall_return_url = window.location.origin
          auth_token = AlumNet.current_token
          #if(AlumNet.environment == "development")
            #paymentwall_return_url = 'http://alumnet-test.aiesec-alumni.org/'

          profile = view.current_user.profile
          birthday = profile.get('born')
          birthday_object = new Date(birthday.year, birthday.month-1, birthday.day)
          parameters_string = 'auth_token='+auth_token+'country_code='+model.get('cc_fips')+'customer[birthday]='+birthday_object.getTime()+'customer[firstname]='+profile.get('first_name')+'customer[lastname]='+profile.get('last_name')+'email='+view.current_user.get("email")+'key='+paymentwall_project_key+'sign_version=2success_url='+paymentwall_return_url+'uid='+view.current_user.get("id")+'widget=p1_1ea9c9cad7ce7d4c6ad745b48f36a9d45'
          #view.ui.divCountry.html('Country set to: '+model.get('cc_fips')+'</br>String: '+parameters_string+'</br></br>Sign calculated: '+CryptoJS.MD5(parameters_string).toString())
          view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription/?key='+paymentwall_project_key+'&widget=p1_1&success_url='+paymentwall_return_url+'&uid='+view.current_user.get("id")+'&email='+view.current_user.get("email")+'&customer[firstname]='+profile.get('first_name')+'&customer[lastname]='+profile.get('last_name')+'&customer[birthday]='+birthday_object.getTime()+'&country_code='+model.get('cc_fips')+'&auth_token='+auth_token+'&sign_version=2&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>')
      this.render()

    onRender: ->
      # view = this
      # auth_token = AlumNet.current_token
      # paymentwall_return_url = window.location.origin
      # profile = view.current_user.profile
      # birthday = profile.get('born')
      # birthday_object = new Date(birthday.year, birthday.month-1, birthday.day)
      
      # #if(AlumNet.environment == "development")
      #   #paymentwall_return_url = 'http://alumnet-test.aiesec-alumni.org/'
      # paymentwall_project_key = AlumNet.paymentwall_project_key
      # #view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription/?key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&widget=p1_1&uid='+view.current_user.get("id")+'&email='+view.current_user.get("email")+'&customer[firstname]='+profile.get('first_name')+'&customer[lastname]='+profile.get('last_name')+'&customer[birthday]='+birthday_object.getTime()+'&country_code='+'&auth_token='+auth_token+'" width="750" height="800" frameborder="0"></iframe>')

      data = CountryList.toSelect2()

      @ui.selectPaymentCountries.select2
        placeholder: "Select a Country"
        data: data

      # @ui.selectPaymentCities.select2
      #   placeholder: "Select a City"

    submitClicked: (e)->
      e.preventDefault()
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
            auth_token = AlumNet.current_token
            paymentwall_return_url = window.location.origin
            birthday = profile.get('born')
            birthday_object = new Date(birthday.year, birthday.month-1, birthday.day)
            paymentwall_project_key = AlumNet.paymentwall_project_key

            parameters_string = 'address='+data.address+'auth_token='+auth_token+'city_id='+data.city_id+'country_code='+model.get('cc_fips')+'country_id='+data.country_id+'customer[birthday]='+birthday_object.getTime()+'customer[firstname]='+profile.get('first_name')+'customer[lastname]='+profile.get('last_name')+'email='+view.current_user.get("email")+'key='+paymentwall_project_key+'sign_version=2success_url='+paymentwall_return_url+'uid='+view.current_user.get("id")+'widget=p1_1ea9c9cad7ce7d4c6ad745b48f36a9d45'
            view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription/?key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&widget=p1_1&uid='+view.current_user.get("id")+'&email='+view.current_user.get("email")+'&customer[firstname]='+profile.get('first_name')+'&customer[lastname]='+profile.get('last_name')+'&customer[birthday]='+birthday_object.getTime()+'&country_code='+model.get('cc_fips')+'&country_id='+data.country_id+'&city_id='+data.city_id+'&address='+data.address+'&auth_token='+auth_token+'&sign_version=2&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>')
            view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription/?key='+paymentwall_project_key+'&widget=p1_1&success_url='+paymentwall_return_url+'&uid='+view.current_user.get("id")+'&email='+view.current_user.get("email")+'&customer[firstname]='+profile.get('first_name')+'&customer[lastname]='+profile.get('last_name')+'&customer[birthday]='+birthday_object.getTime()+'&country_code='+model.get('cc_fips')+'&auth_token='+auth_token+'&sign_version=2&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>')
      else
        $.growl.error({ message: "Please fill address fields" })