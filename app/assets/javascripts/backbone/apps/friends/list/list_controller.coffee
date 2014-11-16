@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    showFriends: ->
      ##this is temporal, current user must be repair.
      current_user = AlumNet.request('temp:current_user')
      friends = AlumNet.request('current_user:friendships:friends')
      console.log friends
      friends.fetch()
      friendsView = new List.FriendsView
        collection: friends

      AlumNet.mainRegion.show(friendsView)

      friendsView.on 'friends:search', (querySearch)->
        @collection.fetch(data: querySearch)