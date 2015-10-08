@AlumNet.module 'PointsApp.Earned', (Earned, @AlumNet, Backbone, Marionette, $, _) ->
  class Earned.Controller
    listEarned: ->
      user_actions = AlumNet.request("history:history", AlumNet.current_user.id)
      points = AlumNet.current_user.profile.get('points')
      if points > 0
      	page = new Earned.ListView
      	collection: user_actions
      else
        page = new Earned.EmptyView
        
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:points:submenu',undefined,1,false)


 