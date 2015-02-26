@AlumNet.module 'PrivacyApp', (PrivacyApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PrivacyApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "privacy/settings": "settings"

  API =
    settings: ()->
      controller = new PrivacyApp.Settings.Controller
      controller.showPrivacy()

 
  AlumNet.addInitializer ->
    new PrivacyApp.Router
      controller: API
