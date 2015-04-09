@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    list: ->
      subscriptionsView = new List.SubscriptionsView
      	current_user: AlumNet.current_user
      AlumNet.mainRegion.show(subscriptionsView)
      #AlumNet.execute('render:events:submenu')

