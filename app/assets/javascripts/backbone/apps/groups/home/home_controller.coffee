@AlumNet.module 'GroupsApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  class Home.Controller
    showGroup: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        #todo: implement a function to return the view. like a discovery module
        homeLayout = new Home.Layout
          model: group
        AlumNet.mainRegion.show(homeLayout)

        homeLayout.on 'show:about', (layout)->
          AlumNet.trigger("groups:about", layout)

      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")