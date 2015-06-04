@AlumNet.module 'ProgramsApp', (ProgramsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class ProgramsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "job-exchange/my-posts": "myJobExchange"
      "job-exchange/new": "createJobExchange"
      "job-exchange/:id/edit": "updateJobExchange"


  API =
    myJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.myJobExchange()
    createJobExchange: ->
      controller = new ProgramsApp.JobExchange.Controller
      controller.createJobExchange()
    updateJobExchange: (id)->
      controller = new ProgramsApp.JobExchange.Controller
      controller.updateJobExchange(id)


  AlumNet.addInitializer ->
    new ProgramsApp.Router
      controller: API