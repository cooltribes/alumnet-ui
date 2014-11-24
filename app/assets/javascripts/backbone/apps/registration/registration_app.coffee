@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  # RegistrationApp.Router = Marionette.AppRouter.extend
  RegistrationApp.Router = AlumNet.Routers.Base.extend
    appRoutes:
      "register": "showRegister"
      "registration/profile": "createProfile"
      "registration/contact": "createContact"
      "registration/experience": "createExperience"

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
      
    createExperience: ->            
      controller = new RegistrationApp.Experience.Controller      
      controller.createExperience()
   

  AlumNet.on "registration:show",  ->
    AlumNet.navigate("register", trigger: true)
    # API.showRegister()

  AlumNet.on "registration:profile",  ->
    AlumNet.navigate("registration/profile")
    API.createProfile()

  AlumNet.on "registration:contact",  ->
    AlumNet.navigate("registration/contact")
    API.createContact()
    
  AlumNet.on "registration:experience:aiesec",  ->
    AlumNet.navigate("registration/experience")
    API.createExperience()
  # AlumNet.on "registration:start",  ->
  #   AlumNet.navigate("registration/experience")
  #   API.createExperience()


  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API