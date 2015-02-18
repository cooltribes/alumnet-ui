@AlumNet.module 'UsersApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'users/submenu/templates/submenu'
    className: 'navTopSubBar'

  API =
    renderSubmenu: (view, options)->      
      AlumNet.submenuRegion.reset() if options.reset
      if view == null
        AlumNet.submenuRegion.empty()
      else
        if view == undefined
          submenu = new Submenu.Menu
        else
          submenu = view
        AlumNet.submenuRegion.show(submenu)        

  AlumNet.commands.setHandler 'render:users:submenu',(view, options = {}) ->
    API.renderSubmenu(view, options)