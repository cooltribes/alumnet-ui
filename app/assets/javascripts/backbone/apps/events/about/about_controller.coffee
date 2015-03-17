@AlumNet.module 'EventsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (id)->
      event = AlumNet.request("event:find", id)
      current_user = AlumNet.current_user
      event.on 'find:success', (response, options)->
        # if group.isClose() && not group.userIsMember()
        #   $.growl.error({ message: "You cannot see information on this Group. This is a Closed Group" })
        # else if group.isSecret() && not group.userIsMember()
        #   AlumNet.trigger('show:error', 404)
        # else
          layout = AlumNet.request("event:layout", event)
          header = AlumNet.request("event:header", event)
          body = new About.View
            model: event
            current_user: current_user

          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(body)
          AlumNet.execute('render:events:submenu')

      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)