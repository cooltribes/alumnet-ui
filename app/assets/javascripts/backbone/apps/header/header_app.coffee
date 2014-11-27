@AlumNet.module 'HeaderApp', (HeaderApp, @AlumNet, Backbone, Marionette, $, _) ->
  HeaderApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "home": "showHeader"

  API =
    showHeader: ->
      controller = new HeaderApp.Menu.Controller
      controller.show()

  AlumNet.addInitializer ->
    new HeaderApp.Router
      controller: API

  AlumNet.addInitializer ->
    API.showHeader()
