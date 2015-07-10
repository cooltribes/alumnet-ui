@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'col-md-8 col-md-offset-3'

    initialize: (options)->
      @current_user = options.current_user
      @condition = options.condition

    ui:
      'selectPaymentCountries': '#js-payment-countries'
      'divCountry': '#country'
      'paymentwallContent': '#paymentwall-content'

    events:
      'change #js-payment-countries': 'reloadWidget'

    templateHelpers: ->
      current_user: @current_user
      condition: @condition

    reloadWidget: (e)->
      country = new AlumNet.Entities.Country
        id: e.val
      view = this
      country.fetch
        success: (model) ->
          paymentwall_project_key = AlumNet.paymentwall_project_key
          paymentwall_return_url = window.location.origin
          auth_token = AlumNet.current_token
          if(AlumNet.environment == "development")
            paymentwall_return_url = 'http://alumnet-test.aiesec-alumni.org/'

          parameters_string = 'auth_token='+auth_token+'country_code='+model.get('cc_fips')+'key='+paymentwall_project_key+'sign_version=2success_url='+paymentwall_return_url+'uid='+view.current_user.get("id")+'widget=p1_1ea9c9cad7ce7d4c6ad745b48f36a9d45'
          #view.ui.divCountry.html('Country set to: '+model.get('cc_fips')+'</br>String: '+parameters_string+'</br></br>Sign calculated: '+CryptoJS.MD5(parameters_string).toString())
          view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription/?key='+paymentwall_project_key+'&widget=p1_1&success_url='+paymentwall_return_url+'&uid='+view.current_user.get("id")+'&country_code='+model.get('cc_fips')+'&auth_token='+auth_token+'&sign_version=2&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="800" frameborder="0"></iframe>')
      this.render()

    onRender: ->
      view = this
      auth_token = AlumNet.current_token
      paymentwall_return_url = window.location.origin
      if(AlumNet.environment == "development")
        paymentwall_return_url = 'http://alumnet-test.aiesec-alumni.org/'
      paymentwall_project_key = AlumNet.paymentwall_project_key
      view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription/?key='+paymentwall_project_key+'&success_url='+paymentwall_return_url+'&widget=p1_1&uid='+view.current_user.get("id")+'&country_code='+'&auth_token='+auth_token+'" width="750" height="800" frameborder="0"></iframe>')

      data = CountryList.toSelect2()

      @ui.selectPaymentCountries.select2
        placeholder: "Select a Country"
        data: data
