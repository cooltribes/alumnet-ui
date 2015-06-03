@AlumNet.module 'PointsApp', (PointsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PointsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "points": "listPackages"
      "points/earned": "listEarned"


  API =
    listPackages: ->
      controller = new PointsApp.Package.Controller
      controller.listPackages()
    listEarned: ->
      controller = new PointsApp.Earned.Controller
      controller.listEarned()

  AlumNet.addInitializer ->
    new PointsApp.Router
      controller: API
