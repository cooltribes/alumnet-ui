@AlumNet.module 'AdminApp.Edit.Events', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  
  	class Edit.Controller
    	showEvents: (id)->
      	layoutView = new Edit.Layout
      	AlumNet.mainRegion.show(layoutView)