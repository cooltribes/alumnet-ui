@AlumNet.module 'FriendsApp', (FriendsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class FriendsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "friends/find": "findFriends"
      "friends/contacts": "importContacts"
      "friends/networks": "importNetworks"
      "friends": "listFriends"
      "approval-requests": "myApproval"

  API =
    findFriends: ->
      document.title = 'AlumNet - Discover Friends'
      controller = new FriendsApp.Find.Controller
      controller.findUsers()
    listFriends: ->
      document.title = 'AlumNet - My Friends'
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
    myApproval: ()->
      document.title = 'AlumNet - Approval requests'
      controller = new FriendsApp.Approval.Controller
      controller.showReceived()
    userFriends: (layout, id)->
      controller = new FriendsApp.List.Controller
      controller.showSomeonesFriends(layout, id)
    userMutual: (layout, id)->
      controller = new FriendsApp.List.Controller
      controller.showMyMutual(layout, id)
    importContacts: ->
      document.title = 'AlumNet - Invite Friends'
      controller = new FriendsApp.Import.Controller
      controller.importContacts()
    importNetworks: ->
      document.title = 'AlumNet - Invite Friends'
      controller = new FriendsApp.Import.Controller
      controller.importNetworks()

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

  AlumNet.on "user:friends:get", (layout, id)->
    API.userFriends(layout, id)

  AlumNet.on "user:friends:mutual", (layout, id)->
    API.userMutual(layout, id)

  AlumNet.on "friends:contacts", ->
    AlumNet.navigate("friends/contacts")
    API.importContacts()

  AlumNet.addInitializer ->
    new FriendsApp.Router
      controller: API
