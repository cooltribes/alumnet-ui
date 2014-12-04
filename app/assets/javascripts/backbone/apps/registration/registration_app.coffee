@AlumNet.module 'RegistrationApp', (RegistrationApp, @AlumNet, Backbone, Marionette, $, _) ->
  RegistrationApp.Router = Marionette.AppRouter.extend
  # RegistrationApp.Router = AlumNet.Routers.Base.extend
    appRoutes:
      "registration": "showRegister"
      "registration/profile": "createProfile"
      "registration/contact": "createContact"
      "registration/experience": "createExperience"
      "registration/skills": "createSkills"

    # onRoute: (name, path, args)  ->
    #   AlumNet.trigger "registration:show"


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

    createApproval: ->
      controller = new RegistrationApp.Approval.Controller
      controller.showApproval()


  AlumNet.on "registration:show",  ->
    API.showRegister()

  AlumNet.on "registration:profile",  ->
    AlumNet.navigate("registration/profile")
    API.createProfile()

  AlumNet.on "registration:contact",  ->
    AlumNet.navigate("registration/contact")
    API.createContact()


  AlumNet.on "registration:experience",  ->
    AlumNet.navigate("registration/experience")
    API.showRegister()

  AlumNet.on "registration:skills",  ->
    AlumNet.navigate("registration/skills")
    API.createSkills()

  AlumNet.on "registration:approval",  ->
    AlumNet.navigate("registration/approval")
    API.createApproval()


  AlumNet.addInitializer ->
    new RegistrationApp.Router
      controller: API