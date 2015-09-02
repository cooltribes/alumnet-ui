@AlumNet.module 'PaymentApp.Checkout', (Checkout, @AlumNet, Backbone, Marionette, $, _) ->
  class Checkout.Controller
    checkout: (condition,data)->
      checkoutView = new Checkout.PaymentView
        current_user: AlumNet.current_user
        condition: condition
        data: data
      AlumNet.mainRegion.show(checkoutView)
