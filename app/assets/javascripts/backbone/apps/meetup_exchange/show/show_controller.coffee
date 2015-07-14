@AlumNet.module 'MeetupExchangeApp.Show', (Show, @AlumNet, Backbone, Marionette, $, _) ->
  class Show.Controller
    show: (id)->
      task = new AlumNet.Entities.MeetupExchange { id: id }
      task.fetch
        success: ->
          showView = new Show.Task
            model: task

          AlumNet.mainRegion.show(showView)
          AlumNet.execute('render:meetup_exchange:submenu')

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)