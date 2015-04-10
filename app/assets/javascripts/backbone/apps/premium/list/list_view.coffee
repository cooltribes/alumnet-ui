@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'col-md-8 col-md-offset-3'

    initialize: (options)->
      @current_user = options.current_user

    ui:
      'selectPaymentCountries': '#js-payment-countries'
      'divCountry': '#country'
      'paymentwallContent': '#paymentwall-content'

    events:
      'change #js-payment-countries': 'reloadWidget'

    templateHelpers: ->
      current_user: @current_user

    reloadWidget: (e)->
      country = new AlumNet.Entities.Country
        id: e.val
      view = this  
      country.fetch
        success: (model) ->
          parameters_string = 'country_code='+model.get('cc_fips')+'key=1acce8f2587d6f7cca456c87cc672bd2success_url=http://alumnet-test.aiesec-alumni.orguid='+view.current_user.get("id")+'widget=p1_1ea9c9cad7ce7d4c6ad745b48f36a9d45'
          view.ui.divCountry.html('Country set to: '+model.get('cc_fips')+'</br>String: '+parameters_string)
          view.ui.paymentwallContent.html('<iframe src="https://api.paymentwall.com/api/subscription/?key=1acce8f2587d6f7cca456c87cc672bd2&widget=p1_1&success_url=http://alumnet-test.aiesec-alumni.org&uid='+view.current_user.get("id")+'&country_code='+model.get('cc_fips')+'&sign='+CryptoJS.MD5(parameters_string).toString()+'" width="750" height="318" frameborder="0"></iframe>')
      this.render()
      
    onRender: ->
      data = CountryList.toSelect2()

      @ui.selectPaymentCountries.select2
        placeholder: "Select a Country"
        data: data

      console.log(CryptoJS.MD5('1234').toString())