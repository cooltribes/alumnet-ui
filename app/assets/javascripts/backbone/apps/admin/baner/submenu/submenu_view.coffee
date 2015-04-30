@AlumNet.module 'AdminApp.BanerSubmenu', (GroupsSubmenu, @AlumNet, Backbone, Marionette, $, _) ->
  class GroupsSubmenu.Menu extends Marionette.ItemView
    template: 'admin/baner/submenu/templates/submenu'

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
          submenu = new GroupsSubmenu.Menu
            tab: tab
        else
          submenu = view
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:admin:baner:submenu',(view,tab) ->
    API.renderSubmenu(view,tab)