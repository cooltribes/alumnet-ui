@AlumNet.module 'GroupsApp', (GroupsApp, @AlumNet, Backbone, Marionette, $, _) ->
  GroupsApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "groups": "listGroups"

  API =
    listGroups: ->
      console.log "routes to group war triggered"
      controller = new GroupsApp.Home.Controller
      controller.listGroups()

  AlumNet.on "groups:home",  ->
    AlumNet.navigate("groups")
    API.listGroups()

  AlumNet.addInitializer ->
    new GroupsApp.Router
      controller: API
