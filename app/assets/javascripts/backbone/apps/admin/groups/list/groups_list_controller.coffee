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
      AlumNet.execute 'show:footer'

      searchView.on 'search', (term)->
        querySearch = { q: name_cont: term }
        groupsTable.collection.fetch
          data: querySearch