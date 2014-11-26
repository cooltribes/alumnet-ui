@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        layout = AlumNet.request("group:layout", group)
        header = AlumNet.request("group:header", group)
          #todo: implement a function to return the view. like a discovery module
        body = new About.View
          model: group

        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)
        AlumNet.execute('render:groups:submenu')

        body.on 'group:edit:description', (model, newValue) ->
          model.save({description: newValue})

        body.on 'group:edit:group_type', (model, newValue) ->
          model.save({group_type: parseInt(newValue)})

      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")
