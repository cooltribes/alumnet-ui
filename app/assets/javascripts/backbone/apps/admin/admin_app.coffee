@AlumNet.module 'AdminApp', (AdminApp, @AlumNet, Backbone, Marionette, $, _) ->

  class AdminApp.Router extends AlumNet.Routers.Admin
    appRoutes:
      "admin/users/stats": "statsList"
      "admin/users/deleted": "usersDeleted"
      "admin/groups/deleted": "groupsDeleted"
      "admin/users/create": "usersCreate"
      "admin/users/:id": "userShow"
      "admin/users": "usersList"
      "admin/groups": "groupsList"
      "admin/regions": "regionsList"
      "admin/users/deleted": "usersDeleted"
      "admin/groups/deleted": "groupsDeleted"
      "admin/banner": "bannerList"
      "admin/actions": "actionsList"
      "admin/prizes": "prizesList"
      "admin/features": "featuresList"
      "dashboard/alumni": "dashboardUsers"
      "admin/users/edit/:id/overview": "showOverview"
      "admin/users/edit/:id/contact": "showContact"
      "admin/users/edit/:id/professional": "showProfessional"
      "admin/users/edit/:id/groups": "showGroups"
      "admin/users/edit/:id/events":"showEvents"
      "admin/users/edit/:id/purchases": "showPurchases"
      "admin/users/edit/:id/points": "showPoints"
      "admin/users/edit/:id/admin": "showAdmin"


  API =
    usersList: (id)->
      controller = new AdminApp.Users.Controller
      controller.usersList(id)
    userShow: (id)->
      controller = new AdminApp.UserShow.Controller
      controller.userShow(id)
    usersDeleted: ->
      controller = new AdminApp.UsersDeleted.Controller
      controller.usersDeleted()
    groupsList: ->
      controller = new AdminApp.GroupsList.Controller
      controller.groupsList()
    groupsDeleted: ->
      controller = new AdminApp.GroupsDeleted.Controller
      controller.groupsDeleted()
    usersCreate: ->
      controller = new AdminApp.UsersCreate.Controller
      controller.create()
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
    dashboardUsers: ->
      # new AdminApp.Dashboard.Users.Controller
    showOverview: (id)->
      controller = new AdminApp.Edit.Overview.Controller
      controller.showOverview(id)
    showContact: (id)->
      controller = new AdminApp.Edit.Contact.Controller
      controller.showContact(id)
    showProfessional: (id)->
      controller = new AdminApp.Edit.Professional.Controller
      controller.showProfessional(id)
    showGroups: (id)->
      controller = new AdminApp.Edit.Groups.Controller
      controller.showGroups(id)
    showEvents: (id)->
      controller = new AdminApp.Edit.Events.Controller
      controller.showEvents(id)
    showPurchases: (id)->
      controller = new AdminApp.Edit.Purchases.Controller
      controller.showPurchases(id)
    showPoints: (id)->
      controller = new AdminApp.Edit.Points.Controller
      controller.showPoints(id)
    showAdmin: (id)->
      controller = new AdminApp.Edit.Admin.Controller
      controller.showAdmin(id)
    showPersonal: (id)->
      controller = new AdminApp.Edit.Controller
      controller.showPersonal(id)

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