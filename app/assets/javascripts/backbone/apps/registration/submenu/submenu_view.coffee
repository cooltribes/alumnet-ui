@AlumNet.module 'RegistrationApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'registration/submenu/templates/submenu'
    className: 'navTopSubBar'

  API =
    renderSubmenu: (view)->
      if view == null
        AlumNet.submenuRegion.empty()
      else
        if view == undefined
          submenu = new Submenu.Menu
        else
          submenu = view
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:registration:submenu',(view) ->
    API.renderSubmenu(view)