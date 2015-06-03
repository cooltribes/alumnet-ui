@AlumNet.module 'TasksApp', (TasksApp, @AlumNet, Backbone, Marionette, $, _) ->
  class TasksApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "job-exchange/new": "createJobExchange"
      "job-exchange/:id/edit": "updateJobExchange"


  API =
    createJobExchange: ->
      controller = new TasksApp.JobExchange.Controller
      controller.createJobExchange()
    updateJobExchange: (id)->
      controller = new TasksApp.JobExchange.Controller
      controller.updateJobExchange(id)


  AlumNet.addInitializer ->
    new TasksApp.Router
      controller: API