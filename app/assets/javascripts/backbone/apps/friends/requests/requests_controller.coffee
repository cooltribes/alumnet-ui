@AlumNet.module 'FriendsApp.Requests', (Requests, @AlumNet, Backbone, Marionette, $, _) ->
  class Requests.Controller
    showRequests: ->
      current_user = AlumNet.current_user
      friendships = AlumNet.request("friendships:received")

      requestsView = new Requests.RequestsView
        # model: group
        collection: friendships

      requestsView.on 'childview:accept', (childView)->
        friendship = childView.model
        friendship.save()
        friendships.remove(friendship)

      AlumNet.mainRegion.show(requestsView)
