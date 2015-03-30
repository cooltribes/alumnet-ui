@AlumNet.module 'GroupsApp.Pictures', (Pictures, @AlumNet, Backbone, Marionette, $, _) ->
  class Pictures.Controller
    showAlbums: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        if group.isClose() && not group.userIsMember()
          $.growl.error({ message: "You cannot see information on this Group. This is a Closed Group" })
        else if group.isSecret() && not group.userIsMember()
          AlumNet.trigger('show:error', 404)
        else
          
          layout = AlumNet.request("group:layout", group)
          header = AlumNet.request("group:header", group)
          
          AlumNet.execute('render:groups:submenu')

          # render the layouts first
          AlumNet.mainRegion.show(layout)
          layout.header.show(header)

          #Show user's albums inside "pictures" region
          AlumNet.trigger "albums:group:list", layout, group        
          

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)  
