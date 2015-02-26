@AlumNet.module 'PagesApp.Terms', (Terms, @AlumNet, Backbone, Marionette, $, _) ->

	class Terms.View extends Marionette.ItemView
    	template: 'pages/terms/templates/terms_of_use'