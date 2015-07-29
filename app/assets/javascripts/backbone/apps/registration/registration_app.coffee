@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  RegistrationApp.Router = Marionette.AppRouter.extend
  # RegistrationApp.Router = AlumNet.Routers.Base.extend
    #Temporal
    appRoutes:
      "registration/profile": "createProfile"
      "registration/contact": "createContact"
      "registration/experience/:step": "createExperience"
      "registration/approval": "createApproval"
      # "registration/skills": "createSkills"

  API =
    activateUser: ->
      controller = new RegistrationApp.Approval.Controller
      controller.activateUser()

    showRegister: ->
      controller = new RegistrationApp.Account.Controller
      controller.showRegister()

    createProfile: ->
      controller = new RegistrationApp.Profile.Controller
      controller.showProfile()

    createContact: ->
      controller = new RegistrationApp.Contact.Controller
      controller.showContact()

    createExperience: (step) ->
      controller = new RegistrationApp.Experience.Controller
      controller.showExperience(step)

    createSkills: ->
      controller = new RegistrationApp.Skills.Controller
      controller.showSkills()

    createApproval: ->
      controller = new RegistrationApp.Approval.Controller
      controller.showApproval()


  AlumNet.on "registration:activate",  ->
    API.activateUser()

  AlumNet.on "registration:show",  ->
    API.showRegister()

  AlumNet.on "registration:profile",  ->
    AlumNet.navigate("registration/profile")
    API.createProfile()

  AlumNet.on "registration:contact",  ->
    AlumNet.navigate("registration/contact")
    API.createContact()

  AlumNet.on "registration:experience", (step) ->
    AlumNet.navigate("registration/experience")
    API.createExperience(step)

  AlumNet.on "registration:skills",  ->
    AlumNet.navigate("registration/skills")
    API.createSkills()

  AlumNet.on "registration:approval",  ->
    AlumNet.navigate("registration/approval")
    API.createApproval()


  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API