@AlumNet.module 'UsersApp.ShoppingCart', (ShoppingCart, @AlumNet, Backbone, Marionette, $, _) ->
  class ShoppingCart.Controller
    showLayoutShoppingCart: -> 
      view = new ShoppingCart.Layout
      AlumNet.mainRegion.show(view)
