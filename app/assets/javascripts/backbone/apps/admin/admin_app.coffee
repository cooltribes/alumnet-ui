@AlumNet.module 'AdminApp', (AdminApp, @AlumNet, Backbone, Marionette, $, _) ->
  
  class AdminApp.Router extends AlumNet.Routers.Admin
    appRoutes:
      "admin/users": "manageUsers"  
  

  API =
    manageUsers: ->
      controller = new AdminApp.Users.Controller
      controller.manageUsers()
    
   

  AlumNet.on "admin:users", ->
    AlumNet.navigate("admin/users")
    API.manageUsers()

  AlumNet.addInitializer ->
    new AdminApp.Router
      controller: API
