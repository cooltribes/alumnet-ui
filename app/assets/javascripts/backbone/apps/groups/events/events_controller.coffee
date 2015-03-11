@AlumNet.module 'GroupsApp.Events', (Events, @AlumNet, Backbone, Marionette, $, _) ->
  class Events.Controller
    createEvent: (group_id)->
      group = AlumNet.request('group:find', group_id)
      current_user = AlumNet.current_user
      group.on 'find:success', (response, options)->
        event = AlumNet.request('event:new', 'groups', group_id)
        console.log event
        createForm = new Events.EventForm
          group: group
          model: event
          user: current_user
        AlumNet.mainRegion.show(createForm)
        AlumNet.execute('render:groups:submenu')

        createForm.on 'form:submit', (model, data)->
          if model.isValid(true)
            options_for_save =
              wait: true
              contentType: false
              processData: false
              data: data
              success: (model, response, options)->
                console.log "Nice!!!"
            model.save(data, options_for_save)

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)


    listEvents: (group_id)->
      group = AlumNet.request("group:find", group_id)
      group.on 'find:success', (response, options)->
      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)
