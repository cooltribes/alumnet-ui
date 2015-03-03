@AlumNet.module 'AdminApp.UsersDeleted', (UsersDeleted, @AlumNet, Backbone, Marionette, $, _) ->
  class UsersDeleted.Controller
    usersDeleted: ->
      usersDeleted = AlumNet.request('user:entities:deleted', {})
      layoutView = new UsersDeleted.Layout
      groupsTable = new UsersDeleted.UsersTable
        collection: usersDeleted

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(groupsTable)
      AlumNet.execute('render:admin:users:submenu', undefined, 1)
