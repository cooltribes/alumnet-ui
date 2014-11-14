@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    showFriends: ->
      ##this is temporal, current user must be repair.
      current_user = AlumNet.request("temp:current_user")
      friends = AlumNet.request("user:friends", current_user.id)
      friends.fetch()
      friendsView = new List.FriendsView
        collection: friends

      AlumNet.mainRegion.show(friendsView)