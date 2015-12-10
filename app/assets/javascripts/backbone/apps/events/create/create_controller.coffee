@AlumNet.module 'EventsApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    createEvent: (user_id)->
      user = AlumNet.current_user ##this is a special case.
      event = AlumNet.request('event:new', 'users', user_id)
      createForm = new Create.EventForm
        model: event
        user: user
      AlumNet.mainRegion.show(createForm)
      #AlumNet.execute('render:events:submenu')

      createForm.on 'form:submit', (model, data)->
        if model.isValid(true)
          options_for_save =
            wait: true
            contentType: false
            processData: false
            data: data
            success: (model, response, options)->
              contacts = AlumNet.request('event:contacts', model.id)
              AlumNet.trigger('user:event:invite', model, contacts)

          model.save(data, options_for_save)

    invitations: (event, users)->
      event.fetch()
      users.fetch()

      usersView = new Create.UsersView
        collection: users
        model: event
      AlumNet.mainRegion.show(usersView)
      #AlumNet.execute('render:events:submenu')
