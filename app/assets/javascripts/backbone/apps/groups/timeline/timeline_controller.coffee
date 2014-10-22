@AlumNet.module 'GroupsApp.Timeline', (Timeline, @AlumNet, Backbone, Marionette, $, _) ->
  class Timeline.Controller
    Timeline: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        timelineLayout = new Timeline.Layout
          model: group
        AlumNet.mainRegion.show(timelineLayout)

        timelineLayout.on 'timeline:about', (layout)->
          AlumNet.trigger("groups:about", layout)

      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")



