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

    donation_checkout: (product_id)->
      checkoutView = new Checkout.DonationPaymentView
        current_user: AlumNet.current_user
        product_id: product_id
      AlumNet.mainRegion.show(checkoutView)
