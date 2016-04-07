@AlumNet.module 'AdminApp.CategoriesSubmenu', (CategoriesSubmenu, @AlumNet, Backbone, Marionette, $, _) ->
  class CategoriesSubmenu.Menu extends Marionette.ItemView
    template: 'admin/categories/submenu/templates/submenu'

    initialize: (options) ->
      @categoriesTable = options.categoriesTable
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
      if view == null
        AlumNet.submenuProduct.empty()
      else
        if view == undefined
          submenu = new CategoriesSubmenu.Menu
            tab: tab
            productTable: table
        else
          submenu = view
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:admin:categories:submenu',(view, tab) ->
    API.renderSubmenu(view, tab)