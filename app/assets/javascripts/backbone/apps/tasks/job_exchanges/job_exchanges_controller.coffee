@AlumNet.module 'TasksApp.JobExchange', (JobExchange, @AlumNet, Backbone, Marionette, $, _) ->
  class JobExchange.Controller
    createJobExchange: ->
      current_user = AlumNet.current_user
      task = new AlumNet.Entities.JobExchange
      createForm = new JobExchange.Form
        model: task
        user: current_user

      AlumNet.mainRegion.show(createForm)
      AlumNet.execute('render:tasks:submenu')