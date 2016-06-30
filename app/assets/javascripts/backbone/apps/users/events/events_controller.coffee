@AlumNet.module 'UsersApp.Events', (Events, @AlumNet, Backbone, Marionette, $, _) ->
  class Events.Controller
    showEvents: (user_id)->
      user = AlumNet.request("user:find", user_id)
      user.on 'find:success', (response, options)->
        layout = AlumNet.request("user:layout", user, 4)
        header = AlumNet.request("user:header", user)
        events = AlumNet.request('event:entities', 'users', user_id)
        eventsView = new Events.EventsView
          model: user
          collection: events

        AlumNet.mainRegion.show(layout)
        AlumNet.execute 'show:footer'
        layout.header.show(header)
        layout.body.show(eventsView)

        #AlumNet.execute('render:users:submenu')

      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)





