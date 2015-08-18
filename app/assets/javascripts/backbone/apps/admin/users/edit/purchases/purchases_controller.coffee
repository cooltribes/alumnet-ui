@AlumNet.module 'AdminApp.Edit.Purchases', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Edit.Controller
    showPurchases: (id)->
      layoutView = new Edit.Layout
      AlumNet.mainRegion.show(layoutView)