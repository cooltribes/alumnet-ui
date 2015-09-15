@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Navbar extends Marionette.ItemView
    template: 'onboarding/navbar/templates/navbar'

    initialize: (options) ->
      @step = options.step || ""
      @class = [
        "", "", ""
        "", ""
      ]  

      @class[@step - 1] = "--active"  
      
    templateHelpers: ->
      classOf: (step) =>
       	@class[step]

 