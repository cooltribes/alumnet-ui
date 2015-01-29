@AlumNet.module 'FriendsApp', (FriendsApp, @AlumNet, Backbone, Marionette, $, _) ->
  # FriendsApp.Router = Marionette.AppRouter.extend
  class FriendsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "friends": "listFriends"
      "friends/find": "findFriends"
      # "friends/received": "receivedRequests"
      # "friends/sent": "sentRequests"

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
    myFriends: (layout)->
      controller = new FriendsApp.List.Controller
      controller.showMyFriends(layout)
    mySent: (layout)->
      controller = new FriendsApp.Requests.Controller
      controller.showMySent(layout)
    myReceived: (layout)->
      controller = new FriendsApp.Requests.Controller
      controller.showMyReceived(layout)

  AlumNet.on "friends:received", ->
    AlumNet.navigate("friends/received")
    API.requestsFriends()
  AlumNet.on "friends:find", ->
    AlumNet.navigate("friends/find")
    API.findFriends()
  AlumNet.on "friends:list", ->
    AlumNet.navigate("friends")
    API.listFriends()

  AlumNet.on "my:friends:get", (layout)->    
    API.myFriends(layout)  

  AlumNet.on "my:friends:sent", (layout)->    
    API.mySent(layout)  
    
  AlumNet.on "my:friends:received", (layout)->    
    API.myReceived(layout)  


  AlumNet.addInitializer ->
    new FriendsApp.Router
      controller: API
