@AlumNet.module 'FriendsApp', (FriendsApp, @AlumNet, Backbone, Marionette, $, _) ->
  # FriendsApp.Router = Marionette.AppRouter.extend
  class FriendsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "friends": "listFriends"
      "friends/find": "findFriends"
      "friends/received": "receivedRequests"
      "friends/sent": "sentRequests"

  API =
    receivedRequests: ->
      controller = new FriendsApp.Requests.Controller
      controller.showReceived()
    sentRequests: ->
      controller = new FriendsApp.Requests.Controller
      controller.showSent()
    findFriends: ->
      controller = new FriendsApp.Find.Controller
      controller.findUsers()
    listFriends: ->
      controller = new FriendsApp.List.Controller
      controller.showFriends()

  AlumNet.on "friends:requests", ->
    AlumNet.navigate("friends/requests")
    API.requestsFriends()
  AlumNet.on "friends:find", ->
    AlumNet.navigate("friends/find")
    API.findFriends()
  AlumNet.on "friends:list", ->
    AlumNet.navigate("friends")
    API.listFriends()

  AlumNet.addInitializer ->
    new FriendsApp.Router
      controller: API
