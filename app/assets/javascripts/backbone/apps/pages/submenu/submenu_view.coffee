@AlumNet.module 'PagesApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'pages/submenu/templates/submenu'
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
        # console.log submenu  
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:pages:submenu',(view) ->    
    API.renderSubmenu(view)