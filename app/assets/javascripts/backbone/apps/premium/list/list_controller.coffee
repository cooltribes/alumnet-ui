@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    list: (condition)->
      subscriptionsView = new List.SubscriptionsView
      	current_user: AlumNet.current_user
      	condition: condition
      AlumNet.mainRegion.show(subscriptionsView)
