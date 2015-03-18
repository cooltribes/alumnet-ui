@AlumNet.module 'EventsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (event_id)->
      event = AlumNet.request("event:find", event_id)
      current_user = AlumNet.current_user
      event.on 'find:success', (response, options)->
        if event.isClose() && not event.userIsInvited()
          $.growl.error({ message: "You cannot see information on this Event. This is a Closed Event" })
        else if event.isSecret() && not event.userIsInvited()
          AlumNet.trigger('show:error', 404)
        else
          layout = AlumNet.request("event:layout", event)
          header = AlumNet.request("event:header", event)
          layoutAbout = new About.Layout
          map = new About.Map
            model: event
          info = new About.View
            model: event
            current_user: current_user

          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(layoutAbout)
          layoutAbout.info.show(info)
          layoutAbout.map.show(map)

          AlumNet.execute('render:events:submenu')

      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)