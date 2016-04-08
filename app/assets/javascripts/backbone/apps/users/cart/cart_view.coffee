@AlumNet.module 'UsersApp.ShoppingCart', (ShoppingCart, @AlumNet, Backbone, Marionette, $, _) ->
  class ShoppingCart.List extends Marionette.ItemView
    template: 'users/cart/templates/list_product'
    className: 'container'

  class ShoppingCart.Layout extends Marionette.LayoutView
    template: 'users/cart/templates/layout'
    childView: ShoppingCart.List
    childViewContainer: '.list-products'

  
