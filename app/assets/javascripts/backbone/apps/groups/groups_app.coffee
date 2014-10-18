@AlumNet.module 'GroupsApp', (GroupsApp, @AlumNet, Backbone, Marionette, $, _) ->
  GroupsApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "groups": "listGroups"
      "groups/new": "createGroup"
      "groups/:id/invite": "inviteUsers"

  API =
    listGroups: ->
      controller = new GroupsApp.Home.Controller
      controller.listGroups()
    createGroup: ->
      controller = new GroupsApp.Create.Controller
      controller.createGroup()
    inviteUsers: (id)->
      controller = new GroupsApp.Invite.Controller
      controller.listUsers(id)

  AlumNet.on "groups:home",  ->
    AlumNet.navigate("groups")
    API.listGroups()

  AlumNet.on "groups:new",  ->
    AlumNet.navigate("groups/new")
    API.createGroup()

  AlumNet.addInitializer ->
    new GroupsApp.Router
      controller: API
