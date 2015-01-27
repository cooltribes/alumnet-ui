@AlumNet.module 'UsersApp.Friends', (Friends, @AlumNet, Backbone, Marionette, $, _) ->
  class Friends.Controller
    showFriends: ()->
      current_user = AlumNet.current_user  

      #Layouts for the profile page - last parameter (2) is for marking "Friends" as active
      layout = AlumNet.request("user:layout", current_user, 2)
      header = AlumNet.request("user:header", current_user)

      friendsLayout = AlumNet.request("my:friends:layout", current_user, 0)

      friendsLayout.on "friends:show:friends", (layout)=>   
        @showMyFriends (layout)
      
      friendsLayout.on "friends:show:received", (layout)=>        
        @showMyReceived (layout)
      
      friendsLayout.on "friends:show:sent", (layout)=>        
        @showMySent (layout)

      friendsLayout.on 'friends:search', (querySearch)->
        friendsCollection.fetch(data: querySearch)
    
    
      AlumNet.mainRegion.show(layout)
      #Show the main profile layout with the body of friends
      layout.header.show(header)
      layout.body.show(friendsLayout)

      #Activate the friends list by default      
      @showMyFriends friendsLayout

      AlumNet.execute('render:users:submenu')

    showMyFriends: (layout)->
      friendsCollection = AlumNet.request('current_user:friendships:friends')
      friendsCollection.fetch()
      friendsView = new AlumNet.FriendsApp.List.FriendsView
        collection: friendsCollection

      layout.body.show(friendsView)


    showMyReceived: (layout)->      
      friendships = AlumNet.request('current_user:friendships:get', 'received')

      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships

      requestsView.on 'childview:accept', (childView)->
        friendship = childView.model
        friendship.save()
        friendships.remove(friendship)

      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)        

      layout.body.show(requestsView)

    showMySent: (layout)->

      friendships = AlumNet.request('current_user:friendships:get', 'sent')
      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships

      layout.body.show(requestsView)


          