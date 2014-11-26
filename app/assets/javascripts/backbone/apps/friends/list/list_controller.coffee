@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    showFriends: ->
      friends = AlumNet.request('current_user:friendships:friends')
      friends.fetch()
      friendsView = new List.FriendsView
        collection: friends

      AlumNet.mainRegion.show(friendsView)
      AlumNet.execute('render:friends:submenu')

      friendsView.on 'friends:search', (querySearch)->
        @collection.fetch(data: querySearch)