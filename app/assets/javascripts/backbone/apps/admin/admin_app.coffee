@AlumNet.module 'AdminApp', (AdminApp, @AlumNet, Backbone, Marionette, $, _) ->

  class AdminApp.Router extends AlumNet.Routers.Admin
    appRoutes:
      "admin/users": "manageUsers"
      "admin/groups": "manageGroups"


  API =
    manageUsers: ->
      controller = new AdminApp.Users.Controller
      controller.manageUsers()
    manageGroups: ->
      controller = new AdminApp.Groups.Controller
      controller.manageGroups()

  AlumNet.addInitializer ->
    new AdminApp.Router
      controller: API

  AlumNet.on "admin:users", ->
    AlumNet.navigate("admin/users")
    API.manageUsers()

  AlumNet.on "admin:groups", ->
    AlumNet.navigate("admin/groups")
    API.manageGroups()
