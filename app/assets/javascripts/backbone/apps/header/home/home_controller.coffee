@AlumNet.module 'HeaderApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  class Home.Controller
    show: ->
      groupsTable = new Home.Header
        
      ###groups = AlumNet.request("group:entities", {})
      groupsTable = new Home.Groups
        collection: groups
      groupsTable.on 'childview:group:delete', (childView, model)->
        groups.remove(model)
      groupsTable.on 'childview:group:show', (childView, model)->
        alert model.escape('description')###

      AlumNet.headerRegion.show(groupsTable)