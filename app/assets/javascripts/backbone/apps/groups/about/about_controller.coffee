@AlumNet.module 'GroupsApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
  class About.Controller
    showAbout: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        layout = AlumNet.request("group:layout")
        header = AlumNet.request("group:header", group)
          #todo: implement a function to return the view. like a discovery module
        body = new About.View
          model: group

        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)

      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")