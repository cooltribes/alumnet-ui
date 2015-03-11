@AlumNet.module 'GroupsApp.Events', (Events, @AlumNet, Backbone, Marionette, $, _) ->
  class Events.Controller
    createEvent: (group_id)->
      group = AlumNet.request('group:find', group_id)
      current_user = AlumNet.current_user
      group.on 'find:success', (response, options)->
        event = AlumNet.request('event:new', 'groups', group_id)
        createForm = new Events.EventForm
          group: group
          model: event
          user: current_user
        AlumNet.mainRegion.show(createForm)
        AlumNet.execute('render:groups:submenu', null)

        createForm.on 'form:submit', (model, data)->
          if model.isValid(true)
            options_for_save =
              wait: true
              contentType: false
              processData: false
              data: data
              success: (model, response, options)->
                contacts = AlumNet.request('event:contacts', 'groups', group_id, model.id)
                AlumNet.trigger('event:invite', model, contacts)

            model.save(data, options_for_save)

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)


    listEvents: (group_id)->
      group = AlumNet.request("group:find", group_id)
      group.on 'find:success', (response, options)->
        if group.userIsMember()
          layout = AlumNet.request("group:layout", group)
          header = AlumNet.request("group:header", group)
          events = AlumNet.request('event:entities', 'groups', group_id)
          events.fetch()
          eventsView = new Events.EventsView
            model: group
            collection: events
          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(eventsView)
          # AlumNet.execute('render:groups:submenu')

        else
          AlumNet.trigger('show:error', 403)
      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)

    invitations: (event, users)->
      event.fetch()
      users.fetch()

      usersView = new Events.UsersView
        collection: users
        model: event
      AlumNet.mainRegion.show(usersView)
      AlumNet.execute('render:groups:submenu', null)


