@AlumNet.module 'GroupsApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  class Home.Controller

    listGroups: ->

      groups = AlumNet.request("group:entities", {})
      groupsTable = @getContainerView(groups)
        
      groupsTable.on 'childview:group:delete', (childView, model)->
        groups.remove(model)
      groupsTable.on 'childview:group:show', (childView, model)->
        alert model.escape('description')
      groupsTable.on 'groups:search', (querySearch)->
        searchedGroups = AlumNet.request("group:entities", querySearch)
      

      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.header_region.show(@getHeaderView())

      
      layoutView.list_region.show(groupsTable)

      # acctually show layout in default (main) region

    getLayoutView: ->
      # List.Layout is in the same module but defined in list_view.coffee file
      new Home.Layout  

    # instantiate views defined in list_view.coffee
    getHeaderView: ->
      new Home.Header        

    getContainerView: (groups) ->
      new Home.Groups
        collection: groups      