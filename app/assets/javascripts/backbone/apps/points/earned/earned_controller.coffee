@AlumNet.module 'PointsApp.Earned', (Earned, @AlumNet, Backbone, Marionette, $, _) ->
  class Earned.Controller
    listEarned: ->
      page = new Earned.EarnedView
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:points:submenu',undefined,1,false)


 