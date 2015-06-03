@AlumNet.module 'TasksApp', (TasksApp, @AlumNet, Backbone, Marionette, $, _) ->
  class TasksApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "job-exchange/new": "createJobExchange"

  API =
    createJobExchange: ->
      controller = new TasksApp.JobExchange.Controller
      controller.createJobExchange()


  AlumNet.addInitializer ->
    new TasksApp.Router
      controller: API