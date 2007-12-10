@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  RegistrationApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "register": "showRegister"
      "registration/profile": "createProfile"

  API =
    showRegister: ->
      controller = new RegistrationApp.Account.Controller
      controller.showRegister()

    createProfile: ->     
      console.log("nelson");      
      controller = new RegistrationApp.Profile.Controller      
      controller.createProfile()
   

  AlumNet.on "registration:register",  ->
    AlumNet.navigate("register")
    API.showRegister()

  AlumNet.on "registration:profile",  ->
    AlumNet.navigate("registration/profile")
    API.createProfile()


  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API

  