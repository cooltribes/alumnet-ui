@AlumNet.module 'PagesApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->

	class Contact.View extends Marionette.ItemView
    	template: 'pages/contact/templates/contact'