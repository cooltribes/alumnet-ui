@AlumNet.module 'FriendsApp.Requests', (Requests, @AlumNet, Backbone, Marionette, $, _) ->
  class Requests.Controller
    showRequests: ->
      current_user = AlumNet.current_user
      friendships = AlumNet.request('current_user:friendships:get', 'received')

      requestsView = new Requests.RequestsView
        collection: friendships

      AlumNet.mainRegion.show(requestsView)

      requestsView.on 'childview:accept', (childView)->
        friendship = childView.model
        friendship.save()
        friendships.remove(friendship)

      requestsView.on 'childview:delete', (childView)->
        friendship = childView.model
        friendship.destroy()
        friendships.remove(friendship)

      requestsView.on 'get:requests', (filter)->
        @collection.fetch(data: { filter: filter })
        @toggleLink(filter)

