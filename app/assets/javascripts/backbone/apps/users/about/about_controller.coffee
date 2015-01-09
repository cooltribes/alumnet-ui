@AlumNet.module 'UsersApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (id)->
      user = AlumNet.request("user:find", id)
      user.on 'find:success', (response, options)->
        # console.log user
      
        layout = AlumNet.request("user:layout", user)
        header = AlumNet.request("user:header", user)
          #todo: implement a function to return the view. like a discovery module
        body = new About.View
          model: user

        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)
        AlumNet.execute('render:users:submenu')

        # body.on 'group:edit:description', (model, newValue) ->
        #   model.save({description: newValue})

        # body.on 'group:edit:group_type', (model, newValue) ->
        #   model.save({group_type: parseInt(newValue)})

      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)
        