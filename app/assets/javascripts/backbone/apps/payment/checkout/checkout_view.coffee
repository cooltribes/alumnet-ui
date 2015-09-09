@AlumNet.module 'PaymentApp.Checkout', (Checkout, @AlumNet, Backbone, Marionette, $, _) ->

  class Checkout.PaymentView extends Marionette.ItemView
    template: 'payment/checkout/templates/payments'
    className: 'col-md-8 col-md-offset-2'

    initialize: (options)->
      document.title = 'AlumNet - Become a member'
      @current_user = options.current_user
      @data = options.data
      @type = options.type

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
      type: @type

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
      view = this
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      valid_address = true
      profile = view.current_user.profile
      address = {}
      _.forEach data, (value, key, list)->
        if value == '' then valid_address = false

      subscription = AlumNet.request('product:find', @data.subscription_id)
      #subscription.on 'find:success', () ->

      if valid_address
        country = new AlumNet.Entities.Country
          id: data.country_id
        
        country.fetch
          success: (model) ->
            paymentwall_project_key = AlumNet.paymentwall_project_key
            paymentwall_secret_key = AlumNet.paymentwall_secret_key
            paymentwall_return_url = window.location.origin
            auth_token = AlumNet.current_token
            
            profile = view.current_user.profile
            birthday = profile.get('born')
            birthday_object = new Date(birthday.year, birthday.month-1, birthday.day)

            parameters_string = 'address='+data.address+'ag_external_id='+subscription.get('sku')+'ag_name='+subscription.get('name')+'ag_type=fixed'+'amount='+subscription.get('price')+'auth_token='+auth_token+'city_id='+data.city_id+'country_code='+model.get('cc_fips')+'country_id='+data.country_id+'currencyCode=EUR'+'customer[address]='+data.address+'customer[birthday]='+birthday_object.getTime()+'customer[country]='+model.get('name')+'customer[firstname]='+profile.get('first_name')+'customer[lastname]='+profile.get('last_name')+'email='+view.current_user.get("email")+'key='+paymentwall_project_key+'payment_type='+view.type+'sign_version=2success_url='+paymentwall_return_url+'uid='+view.current_user.get("id")+'widget=p1_1'+paymentwall_secret_key
            content_html = '<iframe src="https://api.paymentwall.com/api/subscription/?key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&widget=p1_1&uid='+view.current_user.get("id")+'&email='+view.current_user.get("email")+'&customer[firstname]='+profile.get('first_name')+'&customer[lastname]='+profile.get('last_name')+'&customer[birthday]='+birthday_object.getTime()+'&customer[address]='+data.address+'&customer[country]='+model.get('name')+'&amount='+subscription.get('price')+'&currencyCode=EUR&ag_name='+subscription.get('name')+'&ag_external_id='+subscription.get('sku')+'&ag_type=fixed&country_code='+model.get('cc_fips')+'&country_id='+data.country_id+'&city_id='+data.city_id+'&address='+data.address+'&payment_type='+view.type+'&auth_token='+auth_token+'&sign_version=2&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>'

            view.ui.paymentwallContent.html(content_html)
      else
        $.growl.error({ message: "Please fill address fields" })