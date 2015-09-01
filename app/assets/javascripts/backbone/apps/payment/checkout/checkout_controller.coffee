@AlumNet.module 'PaymentApp.Checkout', (Checkout, @AlumNet, Backbone, Marionette, $, _) ->
  class Checkout.Controller
    checkout: (condition,data)->
      #subscriptions = AlumNet.request('product:entities', {q: { feature_eq: 'subscription' }})
      #subscriptions.on 'fetch:success', (collection)->
	  #    subscriptionsView = new List.SubscriptionsView
	  #    	current_user: AlumNet.current_user
	  #    	condition: condition
	  #    	collection: collection
	  #    AlumNet.mainRegion.show(subscriptionsView)
      checkoutView = new Checkout.PaymentView
        current_user: AlumNet.current_user
        condition: condition
        data: data
      AlumNet.mainRegion.show(checkoutView)
