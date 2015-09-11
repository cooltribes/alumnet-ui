@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.User extends AlumNet.Shared.Views.UserView
    template: 'onboarding/alumni/templates/_user'

  class Suggestions.Alumni extends Marionette.CompositeView
    template: 'onboarding/alumni/templates/users'
    childView: Suggestions.User
    childViewContainer: '.users-container'

    initialize: ->
      @collection = new AlumNet.Entities.SuggestedUsersCollection
      @collection.fetch()

    onChildviewCatchUp: ->
      view = @
      @collection.fetch
        success: (collection)->
          view.render()