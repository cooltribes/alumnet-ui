@AlumNet.module 'FriendsApp.Requests', (Requests, @AlumNet, Backbone, Marionette, $, _) ->
  class Requests.Controller
    showMyReceived: (layout)->
      friendships = AlumNet.request('current_user:friendships:get', 'received')

      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships

      requestsView.on 'childview:accept', (childView)->
        friendship = childView.model
        friendship.save()
        friendships.remove(friendship)
        layout.model.decrementCount('pending_received_friendships')
        layout.model.incrementCount('friends')
        $.growl.notice({ message: "Invitation accepted" })

      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)
        layout.model.decrementCount('pending_received_friendships')
        $.growl.notice({ message: "Declined invitation" })

      layout.body.show(requestsView)

    showMySent: (layout)->

      friendships = AlumNet.request('current_user:friendships:get', 'sent')
      requestsView = new AlumNet.FriendsApp.Requests.RequestsView
        collection: friendships

      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)
        layout.model.decrementCount('pending_sent_friendships')

      layout.body.show(requestsView)

    showReceived: ->
      current_user = AlumNet.current_user
      friendships = AlumNet.request('current_user:friendships:get', 'received')

      requestsView = new Requests.RequestsView
        collection: friendships

      current_user = AlumNet.current_user

      layout = AlumNet.request("my:friends:layout", current_user, 2)

      AlumNet.mainRegion.show(layout)

      layout.body.show(requestsView)

      #AlumNet.execute('render:friends:submenu')

      requestsView.on 'childview:accept', (childView)->
        friendship = childView.model
        friendship.save()
        friendships.remove(friendship)
        layout.model.decrementCount('pending_received_friendships')
        layout.model.incrementCount('friends')

      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)
        layout.model.decrementCount('pending_received_friendships')


      requestsView.on 'get:requests', (filter)->
        @collection.fetch(data: { filter: filter })
        @toggleLink(filter)

    showSent: ->
      current_user = AlumNet.current_user
      friendships = AlumNet.request('current_user:friendships:get', 'sent')

      requestsView = new Requests.RequestsView
        collection: friendships

      current_user = AlumNet.current_user

      layout = AlumNet.request("my:friends:layout", current_user, 1)

      AlumNet.mainRegion.show(layout)

      layout.body.show(requestsView)

      AlumNet.execute('render:friends:submenu')

