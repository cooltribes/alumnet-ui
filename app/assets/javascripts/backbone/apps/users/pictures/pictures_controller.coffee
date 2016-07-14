@AlumNet.module 'UsersApp.Pictures', (Pictures, @AlumNet, Backbone, Marionette, $, _) ->
  class Pictures.Controller
    showAlbums: (id)->

      user = AlumNet.request("user:find", id)
      user.on 'find:success', (response, options)->

        #AlumNet.execute('render:users:submenu')  

        #Layouts for the profile page - last parameter (3) is for marking "Pictures" as active tab
        layout = AlumNet.request("user:layout", user, 3)
        header = AlumNet.request("user:header", user)

        AlumNet.mainRegion.show(layout)
        AlumNet.execute 'show:footer'
        
        layout.header.show(header)

        #Show user's albums inside "pictures" region
        AlumNet.trigger "albums:user:list", layout, user        


      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status) 
    