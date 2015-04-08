@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'col-md-8 col-md-offset-3'

    initialize: (options)->
      @current_user = options.current_user
      @country = options.country

    ui:
      'selectPaymentCountries': '#js-payment-countries'
      'divCountry': '#country'

    events:
      'change #js-payment-countries': 'reloadWidget'

    templateHelpers: ->
      current_user: @current_user

    reloadWidget: (e)->
      console.log('reloading')
      console.log(e.val)
      url = AlumNet.api_endpoint + '/countries/' + e.val
      console.log('Url: '+url)
      country = new Entities.Country
      country.set({'id': 5})
      console.log('New country: '+country)
      @country = e.val
      this.render()
      
    onRender: ->
      data = CountryList.toSelect2()

      @ui.selectPaymentCountries.select2
        placeholder: "Select a Country"
        data: data

      @ui.selectPaymentCountries.select2('val', @country)
      @ui.divCountry.html('Country set to: '+@country)