@AlumNet.module 'AdminApp', (AdminApp, @AlumNet, Backbone, Marionette, $, _) ->

  class AdminApp.Router extends AlumNet.Routers.Admin
    appRoutes:
      "admin/users/stats": "statsList"
      "admin/users/deleted": "usersDeleted"
      "admin/groups/deleted": "groupsDeleted"
      "admin/users/create": "usersCreate"
      "admin/users": "usersList"
      "admin/groups": "groupsList"
      "admin/regions": "regionsList"
      "admin/users/deleted": "usersDeleted"
      "admin/groups/deleted": "groupsDeleted"
      "admin/banner": "bannerList"
      "admin/actions": "actionsList"
      "admin/prizes": "prizesList"
      "admin/features": "featuresList"
      "admin/users/:id": "userShow"
      "admin/products": "productsList"
      "admin/products/create": "createProduct"
      "dashboard/alumni": "dashboardUsers"
      "dashboard/posts": "dashboardPosts"
      "admin/emails":"emailsNew"
      "admin/emails-sent":"emailsSent"
      "admin/groups/:group_id/campaigns/:id":"showCampaign"
      "admin/emails-segment":"emailsSegment"
      "admin/products/new": "productsCreate"
      "admin/categories/new": "categoriesCreate"
      "admin/categories": "categoriesList"
      "admin/attributes": "attributesList"
      "admin/attributes/new": "attributesCreate"
      "admin/invoices": "invoices"
      "admin/products/:id/update": "productUpdate"
      "admin/products/:id/prices": "productPrices"

  API =
    usersList: ->
      controller = new AdminApp.Users.Controller
      controller.usersList()
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
    productsList: ->
      controller = new AdminApp.ProductsList.Controller
      controller.productsList()
    createProduct: ->
      controller = new AdminApp.ProductCreate.Controller
      controller.showLayoutCreate()
    dashboardUsers: ->
      new AdminApp.Dashboard.Users.Controller
    dashboardPosts: ->
      new AdminApp.Dashboard.Posts.Controller
    emailsNew: ->
      controller = new AdminApp.EmailsNew.Controller
      controller.emailsNew()
    emailsSent: ->
      controller = new AdminApp.EmailsSent.Controller
      controller.emailsSent()
    showCampaign: (group_id, id)->
      controller = new AdminApp.EmailsShow.Controller
      controller.show(group_id, id)
    emailsSegment: ->
      controller = new AdminApp.EmailsSegment.Controller
      controller.emailsSegment()
    categoriesList: ->
      controller = new AdminApp.CategoriesList.Controller
      controller.categoriesList()
    categoriesCreate: ->
      controller = new AdminApp.CategoriesList.Controller
      controller.create()
    productsCreate: ->
      controller = new AdminApp.ProductsCreate.Controller
      controller.create()
    attributesList: ->
      controller = new AdminApp.AttributesList.Controller
      controller.attributesList()
    attributesCreate: ->
      controller = new AdminApp.AttributesCreate.Controller
      controller.create()
    invoices:->
      controller = new AdminApp.Invoices.Controller
      controller.showLayoutInvoices("all")
    productUpdate: (id)->
      controller = new AdminApp.ProductCreate.Controller
      controller.update(id)
    productPrices: (id)->
      controller = new AdminApp.ProductCreate.Controller
      controller.prices(id)

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

  AlumNet.on "admin:products", ->
    AlumNet.navigate("admin/products")
    API.productsList()

  AlumNet.on "campaign:sent", (group_id, id)->
    #AlumNet.navigate("admin/emails/#{id}")
    #API.showCampaign(group_id, id)
    API.emailsSent()

  AlumNet.on "admin:categories", ->
    AlumNet.navigate("admin/categories")
    API.categoriesList()

  AlumNet.on "admin:attributes", ->
    AlumNet.navigate("admin/attributes")
    API.attributesList()

  AlumNet.on "admin:products:update", (id)->
    AlumNet.navigate("admin/products/#{id}/update")
    API.productUpdate(id)

  AlumNet.on "admin:products:prices", (id)->
    AlumNet.navigate("admin/products/#{id}/prices")
    API.productPrices(id)