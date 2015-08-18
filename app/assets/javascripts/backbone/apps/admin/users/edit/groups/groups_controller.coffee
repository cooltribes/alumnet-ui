@AlumNet.module 'AdminApp.Edit.Groups', (Edit, @AlumNet, Backbone, Marionette, $, _) ->
  
  	class Edit.Controller
    	showGroups: (id)->
      	layoutView = new Edit.Layout
      	AlumNet.mainRegion.show(layoutView)