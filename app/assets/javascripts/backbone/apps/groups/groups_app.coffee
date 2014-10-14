@AlumNet.module 'GroupsApp', (GroupsApp, @AlumNet, Backbone, Marionette, $, _) ->
  GroupsApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "groups": "listGroups"
      "groups/new": "createGroup"

  API =
    listGroups: ->
      controller = new GroupsApp.Home.Controller
      controller.listGroups()
    createGroup: ->
      controller = new GroupsApp.Create.Controller
      controller.createGroup()

  AlumNet.on "groups:home",  ->
    AlumNet.navigate("groups")
    API.listGroups()

  AlumNet.on "groups:new",  ->
    AlumNet.navigate("groups/new")
    API.createGroup()

  AlumNet.addInitializer ->
    new GroupsApp.Router
      controller: API
