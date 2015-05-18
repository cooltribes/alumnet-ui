@AlumNet.module 'EventsApp.Pictures', (Pictures, @AlumNet, Backbone, Marionette, $, _) ->
  class Pictures.Controller
    showAlbums: (id)->
      event = AlumNet.request("event:find", id)
      current_user = AlumNet.current_user
      event.on 'find:success', (response, options)->
        if event.isClose() && not event.userIsInvited()
          $.growl.error({ message: "You cannot see information on this Event. This is a Closed Event" })
        else if event.isSecret() && not event.userIsInvited()
          AlumNet.trigger('show:error', 404)
        else
          AlumNet.execute('render:events:submenu')
          
          layout = AlumNet.request("event:layout", event, 3)
          header = AlumNet.request("event:header", event)


          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          AlumNet.trigger "albums:event:list", layout, event        


      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)