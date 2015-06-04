@AlumNet.module 'AdminApp.GroupsList', (GroupsList, @AlumNet, Backbone, Marionette, $, _) ->
  class GroupsList.Controller
    groupsList: ->
      groups = AlumNet.request('group:entities:admin', {})

      layoutView = new GroupsList.Layout
      searchView = new GroupsList.SearchView
      groupsTable = new GroupsList.GroupsTable
        collection: groups
        linksGroups: []

      AlumNet.mainRegion.show(layoutView)
      layoutView.search.show(searchView)
      layoutView.table.show(groupsTable)
      AlumNet.execute('render:admin:groups:submenu', undefined, 0)

      reRenderTable = (collection)->
        groupsTable.collection = collection if collection
        groupsTable.collection.fetch
          success: ->
            layoutView.table.show(groupsTable, { preventDestroy: true, forceShow: true })

      searchView.on 'search', (term)->
        querySearch = { q: name_cont: term }
        groupsTable.collection.fetch
          data: querySearch

      groupsTable.on 'childview:subgroups:show', (view, subgroups)->
        model = view.model
        @linksGroups.push({id: model.id, name: model.get('name')})
        reRenderTable(subgroups)

      groupsTable.on 'groups:bc',(index, subgroups)->
        newArray = @linksGroups.slice(0, (index + 1))
        @linksGroups = newArray
        reRenderTable(subgroups)

      groupsTable.on 'groups:home', ->
        @linksGroups = []
        reRenderTable(groups)