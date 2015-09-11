@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Member extends Marionette.ItemView
    template: 'onboarding/member/templates/member'