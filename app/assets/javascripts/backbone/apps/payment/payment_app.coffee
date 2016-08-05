@AlumNet.module 'PaymentApp', (PaymentApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PaymentApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "payment": "checkout"
      "donations/:product_id": "donation_checkout"

  API =
    checkout: (data, type)->
      controller = new PaymentApp.Checkout.Controller
      controller.checkout(data, type)
    cc_checkout: (data, type)->
      console.log 'data'
      console.log data
      console.log 'type'
      console.log type
      controller = new PaymentApp.Checkout.Controller
      controller.cc_checkout(data, type)
    donation_checkout: (product_id)->
      console.log 'donations'
      console.log product_id
      controller = new PaymentApp.Checkout.Controller
      controller.donation_checkout(product_id)

  AlumNet.on "payment:checkout", (data, type)->
    API.checkout(data, type)

  AlumNet.on "payment:cc_checkout", (data, type)->
    API.cc_checkout(data, type)

  AlumNet.addInitializer ->
    new PaymentApp.Router
      controller: API
