@AlumNet.module 'AdminApp.ProductsList', (ProductsList, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductsList.Controller
    productsList: ->
      products = AlumNet.request('product:entities', {})
      layoutView = new ProductsList.Layout
      productsTable = new ProductsList.ProductsTable
         collection: products

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(productsTable)
      AlumNet.submenuRegion.empty()
      AlumNet.execute 'show:footer'
      #AlumNet.execute('render:admin:products:submenu', undefined, 0, productsTable)