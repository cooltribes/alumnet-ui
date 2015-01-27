@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    showFriends: ->
      friends = AlumNet.request('current_user:friendships:friends')
      friends.fetch()
      friendsView = new List.FriendsView
        collection: friends
        
      current_user = AlumNet.current_user  
      current_user.fc = 5

      layout = AlumNet.request("my:friends:layout", current_user, 0)

      AlumNet.mainRegion.show(layout)
      layout.body.show(friendsView)

      AlumNet.execute('render:friends:submenu')

      friendsView.on 'friends:search', (querySearch)->
        @collection.fetch(data: querySearch)