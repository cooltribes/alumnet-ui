@AlumNet.module 'GroupsApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.View extends Marionette.ItemView
    template: 'groups/submenu/templates/submenu'

  API =
    renderSubmenu: (view)->
      submenuView = if view == undefined
        new Submenu.View
      else
        view

      AlumNet.submenuRegion.show(submenuView)

  AlumNet.commands.setHandler 'render:group:submenu',(view) ->
    API.renderSubmenu(view)