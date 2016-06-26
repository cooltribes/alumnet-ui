@AlumNet.module 'AdminApp.GroupsDeleted', (GroupsDeleted, @AlumNet, Backbone, Marionette, $, _) ->
  class GroupsDeleted.Controller
    groupsDeleted: ->
      groupsDeleted = AlumNet.request('group:entities:deleted', {})

      layoutView = new GroupsDeleted.Layout
      groupsTable = new GroupsDeleted.GroupsTable
        collection: groupsDeleted

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(groupsTable)
      AlumNet.execute('render:admin:groups:submenu', undefined, 1)
      AlumNet.execute 'show:footer'
