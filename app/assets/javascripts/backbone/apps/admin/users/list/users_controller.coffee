@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->
  class Users.Controller
    usersList: ->
      layoutView = new Users.Layout
      AlumNet.mainRegion.show(layoutView)
      AlumNet.execute('render:admin:users:submenu', undefined, 0)
      AlumNet.execute 'show:footer'

