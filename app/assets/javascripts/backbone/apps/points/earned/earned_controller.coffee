@AlumNet.module 'PointsApp.Earned', (Earned, @AlumNet, Backbone, Marionette, $, _) ->
  class Earned.Controller
    listEarned: ->
      user_actions = AlumNet.request("user_actions:actions", AlumNet.current_user.id)
      page = new Earned.ListView
      	collection: user_actions
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:points:submenu',undefined,1,false)


 