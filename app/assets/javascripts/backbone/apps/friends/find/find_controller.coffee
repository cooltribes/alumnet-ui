@AlumNet.module 'FriendsApp.Find', (Find, @AlumNet, Backbone, Marionette, $, _) ->
  class Find.Controller
    findUsers: ->
      users = AlumNet.request('user:entities', {})
      usersView = new Find.UsersView
        collection: users

      #On fetch, delete current user from the list
      users.on "sync", ()->
        models = this.filter (model)->
          model.get("id") != AlumNet.current_user.id

        this.reset(models)

      AlumNet.mainRegion.show(usersView)
      AlumNet.execute('render:friends:submenu',undefined, 1)

      usersView.on 'childview:request', (childView)->
        attrs = { friend_id: childView.model.id }
        friendship = AlumNet.request('current_user:friendship:request', attrs)
        friendship.on 'save:success', (response, options) ->
          AlumNet.current_user.incrementCount('pending_sent_friendships')  #Sent requests count increased
          childView.removeRequestLink() =>
            AlumNet.current_user.decrementCount('pending_sent_friendships')           
        friendship.on 'save:error', (response, options)->
          console.log response.responseJSON

      usersView.on 'childview:accept', (childView)->
        attrs = childView.model.get('friendship')
        friendship = AlumNet.request('current_user:friendship:request', attrs)
        friendship.on 'save:success', (response, options) ->
          AlumNet.current_user.decrementCount('pending_received_friendships') #Recieved requests count increased
          AlumNet.current_user.incrementCount('friends')
          childView.removeAcceptLink() =>
            AlumNet.current_user.decrementCount('pending_received_friendships') 
          friendship.on 'save:error', (response, options)->
          console.log response.responseJSON


      usersView.on 'users:search', (querySearch)->
        AlumNet.request('user:entities', querySearch)