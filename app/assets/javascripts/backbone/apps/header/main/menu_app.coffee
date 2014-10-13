@AlumNet.module 'MenuApp', (MenuApp, @AlumNet, Backbone, Marionette, $, _) ->
  MenuApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "home": "showHome"

  API =
    listGroups: ->
      console.log "Route to home was triggered"
      controller = new GroupsApp.Home.Controller
      controller.listGroups()

  AlumNet.on "groups:home",  ->
    AlumNet.navigate("groups")
    API.listGroups()

  AlumNet.addInitializer ->
    new MenuApp.Router
      controller: API
