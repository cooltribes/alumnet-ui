@AlumNet.module 'AdminApp.Edit.Admin', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Edit.Controller
    showAdmin: (id)->
      layoutView = new Edit.Layout
      AlumNet.mainRegion.show(layoutView)