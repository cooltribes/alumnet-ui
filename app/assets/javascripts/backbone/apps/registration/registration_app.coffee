@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  RegistrationApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "register": "showRegister"
      "registration/profile": "createProfile"
      "registration/contact": "createContact"

  API =
    showRegister: ->
      controller = new RegistrationApp.Account.Controller
      controller.showRegister()

    createProfile: ->            
      controller = new RegistrationApp.Profile.Controller      
      controller.createProfile()

    createContact: ->            
      controller = new RegistrationApp.Contact.Controller      
      controller.createContact()
   

  AlumNet.on "registration:register",  ->
    AlumNet.navigate("register")
    API.showRegister()

  AlumNet.on "registration:profile",  ->
    AlumNet.navigate("registration/profile")
    API.createProfile()

  AlumNet.on "registration:contact",  ->
    AlumNet.navigate("registration/contact")
    API.createProfile()


  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API

  # last stable