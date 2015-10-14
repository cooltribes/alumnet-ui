@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  RegistrationApp.Router = AlumNet.Routers.Base.extend

    appRoutes:
      "registration/:step": "registration"

  API =
    registration: (step)->
      controller = new RegistrationApp.Main.Controller
      controller.registration(step)
    activateUser: ->
      controller = new RegistrationApp.Main.Controller
      controller.activateUser()

  AlumNet.on "registration:goto", (step)->
    API.registration(step)

  AlumNet.on "registration:activate:user", ->
    API.activateUser()

  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API