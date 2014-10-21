@AlumNet.module 'GroupsApp.Timeline', (Timeline, @AlumNet, Backbone, Marionette, $, _) ->
  class Timeline.Controller
    Timeline: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        aboutView = new Timeline.About
          model: group
        AlumNet.mainRegion.show(aboutView)

      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")



