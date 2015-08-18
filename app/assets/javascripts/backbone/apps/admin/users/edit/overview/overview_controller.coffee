@AlumNet.module 'AdminApp.Edit.Overview', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  
  	class Edit.Controller
    	showOverview: (id)->
      layoutView = new Edit.Layout
      AlumNet.mainRegion.show(layoutView)