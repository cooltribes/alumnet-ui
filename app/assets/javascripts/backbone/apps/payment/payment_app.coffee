@AlumNet.module 'PaymentApp', (PaymentApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PaymentApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "payment": "checkout"


  API =
    checkout: (data, type)->
      controller = new PaymentApp.Checkout.Controller
      controller.checkout(data, type)
    cc_checkout: (data, type)->
      controller = new PaymentApp.Checkout.Controller
      controller.cc_checkout(data, type)

  AlumNet.on "payment:checkout", (data, type)->
    API.checkout(data, type)

  AlumNet.on "payment:cc_checkout", (data, type)->
    API.cc_checkout(data, type)

  AlumNet.addInitializer ->
    new PaymentApp.Router
      controller: API
