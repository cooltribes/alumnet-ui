@AlumNet.module 'AdminApp.GroupsDeleted', (GroupsDeleted, @AlumNet, Backbone, Marionette, $, _) ->
  class GroupsDeleted.Controller
    groupsDeleted: ->
      AlumNet.execute('render:admin:submenu')
      groupsDeleted = AlumNet.request('group:entities:admin', {})

      layoutView = new GroupsDeleted.Layout
      groupsTable = new GroupsDeleted.GroupsTable
        collection: groupsDeleted

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(groupsTable)