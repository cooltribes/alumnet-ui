@AlumNet.module 'GroupsApp.Files', (Files, @AlumNet, Backbone, Marionette, $, _) ->
  class Files.Controller
    listFiles: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        if group.isClose() && not group.userIsMember()
          $.growl.error({ message: "You cannot see information on this Group. This is a Closed Group" })
        else if group.isSecret() && not group.userIsMember()
          AlumNet.trigger('show:error', 404)
        else
          
          layout = AlumNet.request "group:layout", group, 6 #Show "Files" tab active
          header = AlumNet.request "group:header", group
          
          #AlumNet.execute('render:groups:submenu')

          # render the layouts first
          AlumNet.mainRegion.show(layout)
          AlumNet.execute 'show:footer'
          layout.header.show(header)
          
          #Show user's folders inside "files" tab
          AlumNet.trigger "folders:list", layout.body, group        
          

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)  
