@AlumNet.module 'PointsApp', (PointsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PointsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "points": "listPackages"


  API =
    listPackages: ->
      controller = new PointsApp.Package.Controller
      controller.listPackages()

  AlumNet.addInitializer ->
    new PointsApp.Router
      controller: API
