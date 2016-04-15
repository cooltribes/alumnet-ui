@AlumNet.module 'AdminApp.AttributesSubmenu', (AttributesSubmenu, @AlumNet, Backbone, Marionette, $, _) ->
  class AttributesSubmenu.Menu extends Marionette.ItemView
    template: 'admin/attributes/submenu/templates/submenu'

    initialize: (options) ->
      @attributesTable = options.attributesTable
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
    renderSubmenu: (view, tab, table)->
      if view == undefined
        submenu = new AttributesSubmenu.Menu
          tab: tab
          attributesTable: table
      else
        submenu = view
      AlumNet.submenuRegion.reset()
      AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:admin:attributes:submenu',(view, tab) ->
    API.renderSubmenu(view, tab)