@AlumNet.module 'FriendsApp', (FriendsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class FriendsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "friends/find": "findFriends"
      "friends/contacts": "importContacts"
      "friends/networks": "importNetworks"
      "friends": "listFriends"
      "approval-requests": "myApproval"
      "alumni": "mainAlumni"
      "alumni/friends": "friends"
      "alumni/approval": "friendsApproval"
      "alumni/discover": "friendsDiscover"
      "alumni/received": "friendsReceived"

  API =
    findFriends: ->
      AlumNet.setTitle('Discover Friends')
      controller = new FriendsApp.Find.Controller
      controller.findUsers()
    listFriends: ->
      AlumNet.setTitle('My Friends')
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
      AlumNet.setTitle('Approval requests')
      controller = new FriendsApp.Main.Controller
      controller.showMainAlumni("friendsApproval")
      #controller.showApproval()
    userFriends: (layout, id)->
      controller = new FriendsApp.List.Controller
      controller.showSomeonesFriends(layout, id)
    userMutual: (layout, id)->
      controller = new FriendsApp.List.Controller
      controller.showMyMutual(layout, id)
    importContacts: ->
      AlumNet.setTitle('Invite Friends')
      controller = new FriendsApp.Import.Controller
      controller.importContacts()
    importNetworks: ->
      AlumNet.setTitle('Invite Friends')
      controller = new FriendsApp.Import.Controller
      controller.importNetworks()
    friends: ->
      controller = new FriendsApp.Main.Controller
      controller.showMainAlumni("myFriends")
    friendsApproval: ->
      controller = new FriendsApp.Main.Controller
      controller.showMainAlumni("friendsApproval")
    friendsDiscover: ->
      controller = new FriendsApp.Main.Controller
      controller.showMainAlumni("friendsDiscover")
    mainAlumni:->
      AlumNet.setTitle('Alumni')
      controller = new FriendsApp.Main.Controller
      controller.showMainAlumni()
    friendsReceived: ->
      controller = new FriendsApp.Main.Controller
      controller.showMainAlumni("friendsReceived")

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