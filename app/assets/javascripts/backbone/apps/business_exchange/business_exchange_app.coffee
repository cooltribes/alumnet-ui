@AlumNet.module 'BusinessExchangeApp', (BusinessExchangeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class BusinessExchangeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "business-exchange": "discoverBusinessExchange"
      "business-exchange/view-:view": "discoverBusinessExchange"
      "business-exchange/home": "homeBusinessExchange"
      "business-exchange/your-tasks": "yourTasksBusinessExchange"
      "business-exchange/applied": "appliedBusinessExchange"
      "business-exchange/automatches": "automatchesBusinessExchange"
      "business-exchange/invitations": "invitationsBusinessExchange"
      "business-exchange/new": "createBusinessExchange"
      "business-exchange/:id/edit": "updateBusinessExchange"
      "business-exchange/:id": "showBusinessExchange"

  API =
    homeBusinessExchange: ->
      document.title = 'AlumNet - Business Exchange Program'
      new BusinessExchangeApp.Home.Controller
      
    discoverBusinessExchange: (view)->
      document.title = 'AlumNet - Discover Tasks'
      controller = new BusinessExchangeApp.Discover.Controller
      controller.discover(view)
    yourTasksBusinessExchange: ->
      document.title = 'AlumNet - Your Tasks'
      controller = new BusinessExchangeApp.YourTasks.Controller
      controller.your_tasks()
    appliedBusinessExchange: ->
      document.title = 'AlumNet - Applied Tasks'
      controller = new BusinessExchangeApp.Applied.Controller
      controller.applied()
    automatchesBusinessExchange: ->
      document.title = 'AlumNet - Tasks Automatches'
      controller = new BusinessExchangeApp.AutoMatches.Controller
      controller.automatches()
    invitationsBusinessExchange: ->
      document.title = 'AlumNet - Tasks Invitations'
      controller = new BusinessExchangeApp.Invitations.Controller
      controller.invitations()
    createBusinessExchange: ->
      document.title = 'AlumNet - Create a Task'
      controller = new BusinessExchangeApp.Create.Controller
      controller.create()
    updateBusinessExchange: (id)->
      controller = new BusinessExchangeApp.Create.Controller
      controller.update(id)
    showBusinessExchange: (id)->
      controller = new BusinessExchangeApp.Show.Controller
      controller.show(id)

  AlumNet.on "program:business:my", ->
    AlumNet.navigate("business-exchange/your-tasks")
    API.yourTasksBusinessExchange()

  AlumNet.on "program:business:discover", ->
    AlumNet.navigate("business-exchange")
    API.discoverBusinessExchange()

  AlumNet.addInitializer ->
    new BusinessExchangeApp.Router
      controller: API