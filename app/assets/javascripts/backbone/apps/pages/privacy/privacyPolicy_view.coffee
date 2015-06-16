@AlumNet.module 'PagesApp.Privacy', (Privacy, @AlumNet, Backbone, Marionette, $, _) ->

	class Privacy.View extends Marionette.ItemView
    	template: 'pages/privacy/templates/privacy_policy'