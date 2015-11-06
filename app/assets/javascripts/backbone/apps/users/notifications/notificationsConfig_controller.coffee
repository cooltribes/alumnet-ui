@AlumNet.module 'UsersApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
	class Notifications.Controller
		showNotifications: (id)->
			AlumNet.execute('render:users:submenu')
			layout = new Notifications.Layout
			AlumNet.mainRegion.show(layout)
	
			messages_members = new Notifications.messagesMembers
			messages_alument = new Notifications.messagesAlumnet
			events_digest = new Notifications.eventsDigest
			groups_digest = new Notifications.groupsDigest
			notifications = new Notifications.notificationsView
			update = new Notifications.update	
			layout.messages_members.show(messages_members)
			layout.messages_alumnet.show(messages_alument)
			layout.events_digest.show(events_digest)
			layout.groups_digest.show(groups_digest)
			layout.notifications.show(notifications)
			layout.update.show(update)