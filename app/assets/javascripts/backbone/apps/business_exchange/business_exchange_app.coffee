@AlumNet.module 'BusinessExchangeApp', (BusinessExchangeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class BusinessExchangeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      # "business-exchange": "discoverJobExchange"
      # "business-exchange/my-posts": "myJobExchange"
      # "business-exchange/applied": "appliedJobExchange"
      # "business-exchange/automatches": "automatchesJobExchange"
      # "business-exchange/invitations": "invitationsJobExchange"
      "business-exchange/new": "createBusinessExchange"
      "business-exchange/:id/edit": "updateBusinessExchange"
      # "business-exchange/:id": "showJobExchange"

  API =
    # discoverJobExchange: ->
    #   document.title = 'AlumNet - Discover jobs'
    #   controller = new BusinessExchangeApp.JobExchange.Controller
    #   controller.discoverJobExchange()
    # myJobExchange: ->
    #   document.title = 'AlumNet - My jobs'
    #   controller = new BusinessExchangeApp.JobExchange.Controller
    #   controller.myJobExchange()
    # appliedJobExchange: ->
    #   document.title = 'AlumNet - Applied jobs'
    #   controller = new BusinessExchangeApp.JobExchange.Controller
    #   controller.appliedJobExchange()
    # automatchesJobExchange: ->
    #   document.title = 'AlumNet - Automatches'
    #   controller = new BusinessExchangeApp.JobExchange.Controller
    #   controller.automatchesJobExchange()
    # invitationsJobExchange: ->
    #   document.title = 'AlumNet - Job invitations'
    #   controller = new BusinessExchangeApp.JobExchange.Controller
    #   controller.invitationsJobExchange()
    createBusinessExchange: ->
      document.title = 'AlumNet - Create a task'
      controller = new BusinessExchangeApp.Create.Controller
      controller.create()
    updateBusinessExchange: (id)->
      controller = new BusinessExchangeApp.Create.Controller
      controller.update(id)
    # showJobExchange: (id)->
    #   controller = new BusinessExchangeApp.JobExchange.Controller
    #   controller.showJobExchange(id)


  AlumNet.addInitializer ->
    new BusinessExchangeApp.Router
      controller: API