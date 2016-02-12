@AlumNet.module 'BusinessExchangeApp', (BusinessExchangeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class BusinessExchangeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "business-exchange": "discoverBusinessExchange"
      "business-exchange/view-:view": "discoverBusinessExchange"
      "business-exchange/profiles": "profilesBusinessExchange"
      "business-exchange/view-:view": "discoverBusinessExchange"
      "business-exchange/tasks": "businessExchangeTasks"
      "business-exchange/your-tasks": "yourTasksBusinessExchange"
      "business-exchange/applied": "appliedBusinessExchange"
      "business-exchange/automatches": "automatchesBusinessExchange"
      "business-exchange/invitations": "invitationsBusinessExchange"
      "business-exchange/new": "createBusinessExchange"
      "business-exchange/:id/edit": "updateBusinessExchange"
      "business-exchange/:id": "showBusinessExchange"

  API =
    businessExchangeTasks: ->
      AlumNet.setTitle('Business Exchange Tasks')
      controller = new BusinessExchangeApp.Main.Controller
      controller.showMainBusinessExchange("yourTasks")
    discoverBusinessExchange: (view)->
      AlumNet.setTitle('Discover Tasks')
      controller = new BusinessExchangeApp.Discover.Controller
      controller.discover(view)
    yourTasksBusinessExchange: ->
      AlumNet.setTitle('Your Tasks')
      controller = new BusinessExchangeApp.Main.Controller
      controller.showMainBusinessExchange("yourTasks")
    appliedBusinessExchange: ->
      AlumNet.setTitle('Applied Tasks')
      controller = new BusinessExchangeApp.Applied.Controller
      controller.applied()
    automatchesBusinessExchange: ->
      AlumNet.setTitle('Tasks Automatches')
      controller = new BusinessExchangeApp.AutoMatches.Controller
      controller.automatches()
    invitationsBusinessExchange: ->
      AlumNet.setTitle('Tasks Invitations')
      controller = new BusinessExchangeApp.Invitations.Controller
      controller.invitations()
    createBusinessExchange: ->
      AlumNet.setTitle('Create a Task')
      if AlumNet.current_user.get("profinda_api_token")
        controller = new BusinessExchangeApp.Create.Controller
        controller.create()
      else
        AlumNet.getProfindaApiToken()
    updateBusinessExchange: (id)->
      AlumNet.setTitle('Update Task')
      controller = new BusinessExchangeApp.Create.Controller
      controller.update(id)
    showBusinessExchange: (id)->
      AlumNet.setTitle('Task')
      controller = new BusinessExchangeApp.Show.Controller
      controller.show(id)
    profilesBusinessExchange: ()->
      AlumNet.setTitle('Business Exchange Profiles')
      controller = new BusinessExchangeApp.Main.Controller
      controller.showMainBusinessExchange("businessProfiles")

  AlumNet.on "program:business:my", ->
    AlumNet.navigate("business-exchange/your-tasks")
    API.yourTasksBusinessExchange()

  AlumNet.on "program:business:discover", ->
    AlumNet.navigate("business-exchange")
    API.discoverBusinessExchange()

  AlumNet.addInitializer ->
    new BusinessExchangeApp.Router
      controller: API