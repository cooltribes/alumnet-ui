@AlumNet.module 'EventsApp.Files', (Files, @AlumNet, Backbone, Marionette, $, _) ->
  class Files.Controller
    showFiles: (id)->
      event = AlumNet.request("event:find", id)
      current_user = AlumNet.current_user
      event.on 'find:success', (response, options)->
        if event.isClose() && not event.userIsInvited()
          $.growl.error({ message: "You cannot see information on this Event. This is a Closed Event" })
        else if event.isSecret() && not event.userIsInvited()
          AlumNet.trigger('show:error', 404)
        else
          #AlumNet.execute('render:events:submenu')
          
          layout = AlumNet.request("event:layout", event, 5) #Activate tab "Files" (n. 5)
          header = AlumNet.request("event:header", event)


          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          
          #Show user's folders inside "files" tab
          AlumNet.trigger "folders:list", layout.body, event             


      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)