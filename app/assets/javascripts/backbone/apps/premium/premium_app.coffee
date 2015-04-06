@AlumNet.module 'PremiumApp', (PremiumApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PremiumApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "premium": "listPremium"


  API =
    listPremium: (id)->
      controller = new PremiumApp.List.Controller
      controller.list(AlumNet.current_user.id)

  AlumNet.addInitializer ->
    new PremiumApp.Router
      controller: API
