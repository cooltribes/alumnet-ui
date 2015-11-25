@AlumNet.module 'UsersApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
	class Notifications.Controller
		showNotifications: (id)->
			AlumNet.execute('render:users:submenu')
			layout = new Notifications.Layout
			AlumNet.mainRegion.show(layout)

			email_preferences = AlumNet.request("email_preferences:entities", AlumNet.current_user.id)
			email_preferences.on 'fetch:success', (collection)->
				if collection.length == 0
					collection.add([
						{name: 'approval', value: 0, user_id: AlumNet.current_user.id},
						{name: 'friendship', value: 0, user_id: AlumNet.current_user.id}
						{name: 'friendship_accepted', value: 0, user_id: AlumNet.current_user.id}
						{name: 'join_group_invitation', value: 0, user_id: AlumNet.current_user.id}
						{name: 'message', value: 0, user_id: AlumNet.current_user.id}
						{name: 'join_event', value: 0, user_id: AlumNet.current_user.id}
						{name: 'join_group_request', value: 0, user_id: AlumNet.current_user.id}
						])

				messages_members = new Notifications.MessagesMembers
					collection: collection
				layout.messages_members.show(messages_members)
			# messages_alument = new Notifications.messagesAlumnet
			# events_digest = new Notifications.eventsDigest
			# groups_digest = new Notifications.groupsDigest
			# notifications = new Notifications.notificationsView
			# update = new Notifications.update	
			
			# layout.messages_alumnet.show(messages_alument)
			# layout.events_digest.show(events_digest)
			# layout.groups_digest.show(groups_digest)
			# layout.notifications.show(notifications)
			# layout.update.show(update)