@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.User extends AlumNet.Shared.Views.UserView
    template: 'onboarding/alumni/templates/_user'

  class Suggestions.Alumni extends Marionette.CompositeView
    template: 'onboarding/alumni/templates/users'
    childView: Suggestions.User
    childViewContainer: '.users-container'
    className: 'container'

    initialize: ->
      @collection = new AlumNet.Entities.SuggestedUsersCollection
      @collection.fetch()

    templateHelpers: ->
      user_first_name: AlumNet.current_user.profile.get('first_name')

    onRender: ->
      $('body,html').animate({scrollTop: 0}, 600);

    onChildviewCatchUp: ->
      view = @
      @collection.fetch
        success: (collection)->
          view.render()