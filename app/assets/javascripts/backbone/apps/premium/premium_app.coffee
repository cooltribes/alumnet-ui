@AlumNet.module 'PremiumApp', (PremiumApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PremiumApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "premium": "listPremium"


  API =
    listPremium: (condition)->
      controller = new PremiumApp.List.Controller
      controller.list(condition)

  AlumNet.addInitializer ->
    new PremiumApp.Router
      controller: API
