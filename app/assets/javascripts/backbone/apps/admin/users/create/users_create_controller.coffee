@AlumNet.module 'AdminApp.UsersCreate', (UsersCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class UsersCreate.Controller
    create: ->
      formView = new UsersCreate.FormView
      AlumNet.mainRegion.show(formView)
      AlumNet.execute('render:admin:users:submenu', undefined, 3)
