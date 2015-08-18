@AlumNet.module 'AdminApp.Edit.Contact', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Edit.Controller
    showContact: (id)->
      layoutView = new Edit.Layout
      AlumNet.mainRegion.show(layoutView)