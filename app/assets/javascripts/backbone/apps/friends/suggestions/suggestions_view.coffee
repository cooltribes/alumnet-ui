@AlumNet.module 'FriendsApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.User extends AlumNet.Shared.Views.UserView
    template: 'friends/suggestions/templates/_user'

  class Suggestions.FriendsView extends Marionette.CompositeView
    template: 'friends/suggestions/templates/layout'
    childView: Suggestions.User
    childViewContainer: '.users-container'