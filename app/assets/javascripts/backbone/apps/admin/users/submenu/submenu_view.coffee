@AlumNet.module 'AdminApp.UsersSubmenu', (UsersSubmenu, @AlumNet, Backbone, Marionette, $, _) ->
  class UsersSubmenu.Menu extends Marionette.ItemView
    template: 'admin/users/submenu/templates/submenu'

    initialize: (options) ->
      @tab = options.tab
      @class = [
        "", "", ""
        "", ""
      ]
      @class[parseInt(@tab)] = "active"

    templateHelpers: ->
      model = @model
      classOf: (step) =>
        @class[step]

  API =
    renderSubmenu: (view,tab)->
      if view == null
        AlumNet.submenuRegion.empty()
      else
        if view == undefined
          submenu = new UsersSubmenu.Menu
            tab: tab
        else
          submenu = view
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:admin:users:submenu',(view,tab) ->
    API.renderSubmenu(view,tab)