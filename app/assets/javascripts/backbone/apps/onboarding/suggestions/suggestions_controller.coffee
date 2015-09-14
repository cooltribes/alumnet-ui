@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Controller
    onboarding: ->
      layoutView = new Suggestions.Layout
      AlumNet.mainRegion.show(layoutView)
      # alert "En OnboardingApp"


