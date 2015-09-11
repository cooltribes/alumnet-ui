@AlumNet.module 'JobExchangeApp', (JobExchangeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class JobExchangeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "job-exchange": "discoverJobExchange"
      "job-exchange/my-posts": "myJobExchange"
      "job-exchange/applied": "appliedJobExchange"
      "job-exchange/automatches": "automatchesJobExchange"
      "job-exchange/invitations": "invitationsJobExchange"
      "job-exchange/new": "createJobExchange"
      "job-exchange/:id/edit": "updateJobExchange"
      "job-exchange/:id": "showJobExchange"

  API =
    discoverJobExchange: ->
      document.title = 'AlumNet - Discover jobs'
      controller = new JobExchangeApp.Discover.Controller
      controller.discover()
    myJobExchange: ->
      document.title = 'AlumNet - My jobs'
      controller = new JobExchangeApp.MyJobs.Controller
      controller.myJobs()
    appliedJobExchange: ->
      document.title = 'AlumNet - Applied jobs'
      controller = new JobExchangeApp.Applied.Controller
      controller.applied()
    automatchesJobExchange: ->
      document.title = 'AlumNet - Automatches'
      controller = new JobExchangeApp.AutoMatches.Controller
      controller.automatches()
    invitationsJobExchange: ->
      document.title = 'AlumNet - Job invitations'
      controller = new JobExchangeApp.Invitations.Controller
      controller.invitations()
    createJobExchange: ->
      document.title = 'AlumNet - Post a job'
      controller = new JobExchangeApp.Create.Controller
      controller.create()
    updateJobExchange: (id)->
      controller = new JobExchangeApp.Create.Controller
      controller.update(id)
    showJobExchange: (id)->
      controller = new JobExchangeApp.Show.Controller
      controller.show(id)

  AlumNet.on "program:job:my", ->
    AlumNet.navigate("job-exchange/my-posts")
    API.myJobExchange()

  AlumNet.on "program:job:discover", ->
    AlumNet.navigate("job-exchange")
    API.discoverJobExchange()

  AlumNet.addInitializer ->
    new JobExchangeApp.Router
      controller: API