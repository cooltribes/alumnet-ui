@AlumNet.module 'PagesApp.Donate', (Donate, @AlumNet, Backbone, Marionette, $, _) ->

	class Donate.View extends Marionette.ItemView
    	template: 'pages/donate/templates/donate'

    	initialize: ()->
    		document.title='AlumNet - Donate to the AAI Seed'