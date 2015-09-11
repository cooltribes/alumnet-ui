@AlumNet.module 'OnboardingApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    onboarding: ->
      layoutView = new Main.Layout
      AlumNet.mainRegion.show(layoutView)
      # alert "En OnboardingApp"


