@AlumNet.module 'PagesApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->

	class Contact.View extends Marionette.ItemView
		template: 'pages/contact/templates/contact'

		events:
			'click button.js-submit': 'submitClicked'

		submitClicked: (e)->
			e.preventDefault()
			data = Backbone.Syphon.serialize(this)
			data.user_id = AlumNet.current_user.id
			if data.message == ""
				$.growl.error({ message: 'Please write a message' })
			else
				Backbone.ajax
					url: AlumNet.api_endpoint + '/contact'
					type: 'POST'
					data: data
					error: (xhr)->
						$.growl.error({ message: xhr.statusText })
					success: (data)->
						$.growl.notice({ message: "Message sent!" })
						$("#message").val("")