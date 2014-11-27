@AlumNet.module 'HeaderApp.Menu', (Menu, @AlumNet, Backbone, Marionette, $, _) ->
  class Menu.Controller
    show: ->
      current_user = AlumNet.request 'get:current_user'
      menuView = new Menu.MenuBar
        model: current_user
      AlumNet.headerRegion.show(menuView)