@AlumNet.module 'FriendsApp', (FriendsApp, @AlumNet, Backbone, Marionette, $, _) ->
  FriendsApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "friends": "listFriends"
      "friends/find": "findFriends"
      "friends/requests": "requestsFriends"

  API =
    requestsFriends: ->
      controller = new FriendsApp.Requests.Controller
      controller.showRequests()
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
