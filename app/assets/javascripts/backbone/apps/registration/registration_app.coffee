@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  RegistrationApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "registration/:step": "registration"

  API =
    registration: (step)->
      controller = new RegistrationApp.Main.Controller
      controller.registration(step)

  AlumNet.on "registration:goto", (step)->
    API.registration(step)

  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API