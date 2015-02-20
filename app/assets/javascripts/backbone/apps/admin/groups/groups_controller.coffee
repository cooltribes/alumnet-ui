@AlumNet.module 'AdminApp.Groups', (Groups, @AlumNet, Backbone, Marionette, $, _) ->
  class Groups.Controller
    manageGroups: ->
      AlumNet.execute('render:admin:submenu')
      groups = AlumNet.request('group:entities:admin', {})

      layoutView = new Groups.Layout
      groupsTable = new Groups.GroupsTable
        collection: groups

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(groupsTable)
