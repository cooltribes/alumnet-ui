@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  RegistrationApp.Router = Marionette.AppRouter.extend
  # RegistrationApp.Router = AlumNet.Routers.Base.extend
    appRoutes:
      "registration": "showRegister"
      "registration/profile": "createProfile"
      "registration/contact": "createContact"
      "registration/experience": "createExperience"
      "registration/skills": "createSkills"

    onRoute: (name, path, args)  ->
      # AlumNet.trigger "registration:show"
        

  API =
    showRegister: ->
      controller = new RegistrationApp.Account.Controller
      controller.showRegister()

    createProfile: ->            
      controller = new RegistrationApp.Profile.Controller      
      controller.showProfile()

    createContact: ->            
      controller = new RegistrationApp.Contact.Controller      
      controller.showContact()
      
    createExperience: ->            
      controller = new RegistrationApp.Experience.Controller      
      controller.showExperience()

    createSkills: ->            
      controller = new RegistrationApp.Skills.Controller      
      controller.showSkills()
   

  AlumNet.on "registration:show",  ->
    # AlumNet.navigate("registration", trigger: true)
    API.showRegister()

  AlumNet.on "registration:profile",  ->
    AlumNet.navigate("registration/profile")
    API.createProfile()

  AlumNet.on "registration:contact",  ->
    AlumNet.navigate("registration/contact")
    API.createContact()
    

  AlumNet.on "registration:experience",  ->
    AlumNet.navigate("registration/experience")
    API.createExperience()

  AlumNet.on "registration:skills",  ->
    AlumNet.navigate("registration/skills")
    API.createSkills()


  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API