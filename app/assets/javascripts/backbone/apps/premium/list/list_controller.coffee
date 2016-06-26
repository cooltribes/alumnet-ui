@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    list: ()->
      subscriptions = AlumNet.request('product:entities', {q: { feature_eq: 'subscription', status_eq: 1 }})
      subscriptions.on 'fetch:success', (collection)->
	      subscriptionsView = new List.SubscriptionsView
	      	current_user: AlumNet.current_user
	      	collection: collection
	      AlumNet.mainRegion.show(subscriptionsView)
      	AlumNet.execute 'show:footer'
