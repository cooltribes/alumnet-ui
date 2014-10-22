@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  RegistrationApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "register": "showRegister"

  API =
    showRegister: ->
      controller = new RegistrationApp.Account.Controller
      controller.showRegister()
   

  AlumNet.on "registration:register",  ->
    AlumNet.navigate("register")
    API.showRegister()


  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API
