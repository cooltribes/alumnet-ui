@AlumNet.module 'FriendsApp.Submenu', (Submenu, @AlumNet, Backbone, Marionette, $, _) ->
  class Submenu.Menu extends Marionette.ItemView
    template: 'friends/submenu/templates/submenu'
    className: 'navTopSubBar'

    ui:
      'linkMenu':'.navbar-nav li a'

    events:
      'click @ui.linkMenu': 'clickLink'

    clickLink: (e) ->
      $(e.currentTarget).parent().addClass("active")
      $(e.currentTarget).parent().parent().siblings().children().removeClass("active")

  API =
    renderSubmenu: (view)->
      if view == null
        AlumNet.submenuRegion.empty()
      else
        if view == undefined
          submenu = new Submenu.Menu
        else
          submenu = view
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:friends:submenu',(view) ->
    API.renderSubmenu(view)