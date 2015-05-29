@AlumNet.module 'PagesApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->

	class About.View extends Marionette.ItemView
    	template: 'pages/about/templates/about'

    	initialize: ()->
    		document.title='AlumNet - About AIESSEC Alumni International'