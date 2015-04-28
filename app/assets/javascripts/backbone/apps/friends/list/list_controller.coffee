@AlumNet.module 'FriendsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    showFriends: ->
        
      current_user = AlumNet.current_user  

      friendsLayout = AlumNet.request("users:friends:layout", current_user, 0)

      friendsLayout.on "friends:show:myfriends", (layout)->  
        AlumNet.trigger "my:friends:get", layout        
      
      friendsLayout.on "friends:show:received", (layout)=>        
        AlumNet.trigger "my:friends:received", layout
      
      friendsLayout.on "friends:show:sent", (layout)=>        
        AlumNet.trigger "my:friends:sent", layout        
      
      friendsLayout.on "show:approval:requests", (layout)=>        
        AlumNet.trigger "my:approval:requests", layout        

      friendsLayout.on 'friends:search', (querySearch, collection)->        
        collection.fetch(data: querySearch)

      AlumNet.execute('render:friends:submenu',undefined, 0)

      AlumNet.mainRegion.show(friendsLayout)
      
      AlumNet.trigger "my:friends:get", friendsLayout

    showMyFriends: (layout)->
      friendsCollection = AlumNet.request('current_user:friendships:friends')
      friendsCollection.fetch()
      friendsView = new List.FriendsView
        collection: friendsCollection

      layout.body.show(friendsView)                

    showSomeonesFriends: (layout, id)->
      friendsCollection = AlumNet.request('user:friendships:friends', id)
      friendsCollection.fetch()
      friendsView = new List.FriendsView
        collection: friendsCollection
      layout.body.show(friendsView)

    showMyMutual: (layout, id)->
      friendsCollection = AlumNet.request('user:friendships:mutual', id)
      friendsCollection.fetch()
      friendsView = new List.FriendsView
        collection: friendsCollection
      
      layout.body.show(friendsView)  
