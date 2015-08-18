@AlumNet.module 'AdminApp.Edit.Points', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Edit.Controller
    showPoints: (id)->
      layoutView = new Edit.Layout
      AlumNet.mainRegion.show(layoutView)