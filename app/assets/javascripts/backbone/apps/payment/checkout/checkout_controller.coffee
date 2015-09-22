@AlumNet.module 'PaymentApp.Checkout', (Checkout, @AlumNet, Backbone, Marionette, $, _) ->
  class Checkout.Controller
    checkout: (data, type)->
      checkoutView = new Checkout.PaymentView
        current_user: AlumNet.current_user
        data: data
        type: type
      AlumNet.mainRegion.show(checkoutView)

    cc_checkout: (data, type)->
      checkoutView = new Checkout.CCPaymentView
        current_user: AlumNet.current_user
        data: data
        type: type
      AlumNet.mainRegion.show(checkoutView)
