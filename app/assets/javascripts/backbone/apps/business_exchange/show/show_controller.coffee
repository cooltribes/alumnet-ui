@AlumNet.module 'BusinessExchangeApp.Show', (Show, @AlumNet, Backbone, Marionette, $, _) ->
  class Show.Controller
    show: (id)->
      task = new AlumNet.Entities.BusinessExchange { id: id }
      task.fetch
        success: ->
          showView = new Show.Task
            model: task

          AlumNet.mainRegion.show(showView)
          AlumNet.execute('render:business_exchange:submenu')

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)