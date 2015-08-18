@AlumNet.module 'AdminApp.Edit.Professional', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  
  class Edit.Controller
    showProfessional: (id)->
      layoutView = new Edit.Layout
      AlumNet.mainRegion.show(layoutView)