@AlumNet.module 'OnboardingApp', (OnboardingApp, @AlumNet, Backbone, Marionette, $, _) ->
  class OnboardingApp.Router extends AlumNet.Routers.Base

  API =
    onboarding: ->
      controller = new OnboardingApp.Suggestions.Controller
      controller.onboarding()

  AlumNet.on "show:onboarding", ->
    API.onboarding()

  AlumNet.addInitializer ->
    new OnboardingApp.Router
      controller: API