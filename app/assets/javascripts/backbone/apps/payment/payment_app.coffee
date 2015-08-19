@AlumNet.module 'PaymentApp', (PaymentApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PaymentApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "payment": "checkout"


  API =
    checkout: (condition,data)->
      console.log "entro aqui"
      controller = new PaymentApp.Checkout.Controller
      controller.checkout(condition,data)

  AlumNet.on "payment:checkout", (data)->
    AlumNet.navigate("payment/checkout")
    API.checkout('',data)

  AlumNet.addInitializer ->
    new PaymentApp.Router
      controller: API
