@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    list: (condition)->
      subscriptions = AlumNet.request('product:entities', {q: { feature_eq: 'subscription' }})
      subscriptions.on 'fetch:success', (collection)->
	      subscriptionsView = new List.SubscriptionsView
	      	current_user: AlumNet.current_user
	      	condition: condition
	      	collection: collection
	      AlumNet.mainRegion.show(subscriptionsView)
