@AlumNet.module 'ProgramsApp', (ProgramsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class ProgramsApp.Router extends AlumNet.Routers.Base
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
      controller = new ProgramsApp.JobExchange.Controller
      controller.discoverJobExchange()
    myJobExchange: ->
      document.title = 'AlumNet - My jobs'
      controller = new ProgramsApp.JobExchange.Controller
      controller.myJobExchange()
    appliedJobExchange: ->
      document.title = 'AlumNet - Applied jobs'
      controller = new ProgramsApp.JobExchange.Controller
      controller.appliedJobExchange()
    automatchesJobExchange: ->
      document.title = 'AlumNet - Automatches'
      controller = new ProgramsApp.JobExchange.Controller
      controller.automatchesJobExchange()
    invitationsJobExchange: ->
      document.title = 'AlumNet - Job invitations'
      controller = new ProgramsApp.JobExchange.Controller
      controller.invitationsJobExchange()
    createJobExchange: ->
      document.title = 'AlumNet - Create a job'
      controller = new ProgramsApp.JobExchange.Controller
      controller.createJobExchange()
    updateJobExchange: (id)->
      controller = new ProgramsApp.JobExchange.Controller
      controller.updateJobExchange(id)
    showJobExchange: (id)->
      controller = new ProgramsApp.JobExchange.Controller
      controller.showJobExchange(id)

  AlumNet.on "program:job:my", ->
    AlumNet.navigate("job-exchange/my-posts")
    API.myJobExchange()

  AlumNet.on "program:job:discover", ->
    AlumNet.navigate("job-exchange")
    API.discoverJobExchange()

  AlumNet.addInitializer ->
    new ProgramsApp.Router
      controller: API