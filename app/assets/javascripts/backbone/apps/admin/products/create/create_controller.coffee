@AlumNet.module 'AdminApp.ProductsCreate', (ProductsCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductsCreate.Controller
    create: ->
      layoutView = new ProductsCreate.Layout
      product = new AlumNet.Entities.Product
      createForm = new ProductsCreate.CreateForm
        model: product
      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(createForm)
      AlumNet.execute('render:admin:products:submenu', undefined, 1)