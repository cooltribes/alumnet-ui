@AlumNet.module 'AdminApp.ProductsSubmenu', (ProductsSubmenu, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductsSubmenu.Menu extends Marionette.ItemView
    template: 'admin/products/submenu/templates/submenu'

    initialize: (options) ->
      @productTable = options.productTable
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
          submenu = new ProductsSubmenu.Menu
            tab: tab
            productTable: table
        else
          submenu = view
        AlumNet.submenuRegion.reset()
        AlumNet.submenuRegion.show(submenu)

  AlumNet.commands.setHandler 'render:admin:products:submenu',(view, tab, table) ->
    API.renderSubmenu(view, tab, table)