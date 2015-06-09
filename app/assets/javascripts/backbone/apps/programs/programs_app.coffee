@AlumNet.module 'ProgramsApp', (ProgramsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class ProgramsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "job-exchange": "discoverJobExchange"
      "job-exchange/my-posts": "myJobExchange"
      "job-exchange/automatches": "automatchesJobExchange"
      "job-exchange/new": "createJobExchange"
      "job-exchange/:id/edit": "updateJobExchange"
      "job-exchange/:id": "showJobExchange"

  API =
    discoverJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.discoverJobExchange()
    automatchesJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.automatchesJobExchange()
    myJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.myJobExchange()
    createJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.createJobExchange()
    showJobExchange: (id)->
      controller = new ProgramsApp.JobExchange.Controller
      controller.showJobExchange(id)
    updateJobExchange: (id)->
      controller = new ProgramsApp.JobExchange.Controller
      controller.updateJobExchange(id)

  AlumNet.on "program:job:my", ->
    AlumNet.navigate("job-exchange/my-posts")
    API.myJobExchange()

  AlumNet.on "program:job:discover", ->
    AlumNet.navigate("job-exchange")
    API.discoverJobExchange()

  AlumNet.addInitializer ->
    new ProgramsApp.Router
      controller: API