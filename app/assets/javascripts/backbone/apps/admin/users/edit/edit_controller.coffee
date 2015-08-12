@AlumNet.module 'AdminApp.Edit', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  class Edit.Controller
    showPersonal: (id)->
      layoutView = new Edit.Layout

      AlumNet.mainRegion.show(layoutView)

