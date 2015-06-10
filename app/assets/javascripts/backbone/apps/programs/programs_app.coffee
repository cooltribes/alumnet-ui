@AlumNet.module 'ProgramsApp', (ProgramsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class ProgramsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "job-exchange": "discoverJobExchange"
      "job-exchange/my-posts": "myJobExchange"
      "job-exchange/applied": "appliedJobExchange"
      "job-exchange/automatches": "automatchesJobExchange"
      "job-exchange/new": "createJobExchange"
      "job-exchange/:id/edit": "updateJobExchange"
      "job-exchange/:id": "showJobExchange"

  API =
    discoverJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.discoverJobExchange()
    myJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.myJobExchange()
    appliedJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.appliedJobExchange()
    automatchesJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.automatchesJobExchange()
    createJobExchange: ->
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