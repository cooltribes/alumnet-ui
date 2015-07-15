@AlumNet.module 'AdminApp', (AdminApp, @AlumNet, Backbone, Marionette, $, _) ->

  class AdminApp.Router extends AlumNet.Routers.Admin
    appRoutes:
      "admin/users/stats": "statsList"
      "admin/users/deleted": "usersDeleted"
      "admin/groups/deleted": "groupsDeleted"
      "admin/users/:id": "usersList"
      "admin/users": "usersList"
      "admin/groups": "groupsList"
      "admin/regions": "regionsList"
      "admin/users/deleted": "usersDeleted"
      "admin/groups/deleted": "groupsDeleted"
      "admin/banner": "bannerList"
      "admin/actions": "actionsList"
      "admin/prizes": "prizesList"
      "admin/features": "featuresList"
      # "dashboard/alumni": "dashboardUsers"

  API =
    usersList: (id)->
      controller = new AdminApp.Users.Controller
      controller.usersList(id)
    usersDeleted: ->
      controller = new AdminApp.UsersDeleted.Controller
      controller.usersDeleted()
    groupsList: ->
      controller = new AdminApp.GroupsList.Controller
      controller.groupsList()
    groupsDeleted: ->
      controller = new AdminApp.GroupsDeleted.Controller
      controller.groupsDeleted()
    regionsList: ->
      controller = new AdminApp.Regions.Controller
      controller.regionsList()
    bannerList: ->
      controller = new AdminApp.BannerList.Controller
      controller.bannerList()   
    statsList: ->
      controller = new AdminApp.UserStats.Controller
      controller.showStats()
    actionsList: ->
      controller = new AdminApp.ActionsList.Controller
      controller.actionsList()
    prizesList: ->
      controller = new AdminApp.PrizesList.Controller
      controller.prizesList()
    featuresList: ->
      controller = new AdminApp.FeaturesList.Controller
      controller.featuresList()

  AlumNet.addInitializer ->
    new AdminApp.Router
      controller: API

  AlumNet.on "admin:users", ->
    AlumNet.navigate("admin/users")
    API.usersList()

  AlumNet.on "admin:groups", ->
    AlumNet.navigate("admin/groups")
    API.groupsList()

  AlumNet.on "admin:groups:deleted", ->
    AlumNet.navigate("admin/groups/deleted")
    API.groupsDeleted()

  AlumNet.on "admin:banner", ->
    AlumNet.navigate("admin/banner")
    API.bannerList()

  AlumNet.on "admin:actions", ->
    AlumNet.navigate("admin/actions")
    API.groupsList()

  AlumNet.on "admin:features", ->
    AlumNet.navigate("admin/features")
    API.featuresList()