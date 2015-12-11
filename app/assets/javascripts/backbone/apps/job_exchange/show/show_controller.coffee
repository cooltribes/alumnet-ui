@AlumNet.module 'JobExchangeApp.Show', (Show, @AlumNet, Backbone, Marionette, $, _) ->
  class Show.Controller
    show: (id)->
      task = new AlumNet.Entities.JobExchange { id: id }
      task.fetch
        success: ->
          detailView = new Show.Task
            model: task
          AlumNet.mainRegion.show(detailView)
          #AlumNet.execute('render:job_exchange:submenu')

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)