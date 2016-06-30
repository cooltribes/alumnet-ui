@AlumNet.module 'MeetupExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    create: ->
      task = new AlumNet.Entities.MeetupExchange
      createForm = new Create.Form
        model: task

      AlumNet.mainRegion.show(createForm)
      AlumNet.execute 'show:footer'
      #AlumNet.execute('render:meetup_exchange:submenu')

    update: (id)->
      current_user = AlumNet.current_user
      task = new AlumNet.Entities.MeetupExchange { id: id }
      task.fetch
        success: ->
          if task.canEdit()
            createForm = new Create.Form
              model: task
              user: current_user

            AlumNet.mainRegion.show(createForm)
            #AlumNet.execute('render:meetup_exchange:submenu')
          else
            AlumNet.trigger('show:error', 403)

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)