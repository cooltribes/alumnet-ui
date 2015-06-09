@AlumNet.module 'ProgramsApp', (ProgramsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class ProgramsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "job-exchange/my-posts": "myJobExchange"
      "job-exchange/new": "createJobExchange"
      "job-exchange/:id/edit": "updateJobExchange"
      "job-exchange/:id": "showJobExchange"


  API =
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

  AlumNet.addInitializer ->
    new ProgramsApp.Router
      controller: API