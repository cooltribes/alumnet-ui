@AlumNet.module 'UsersApp.Notifications', (Notifications, @AlumNet, Backbone, Marionette, $, _) ->
	class Notifications.Controller
		showNotifications: (id)->
			#AlumNet.execute('render:users:submenu')
			layout = new Notifications.Layout
			AlumNet.mainRegion.show(layout)

			messages_preferences = AlumNet.request("email_preferences:messages", AlumNet.current_user.id)
			messages_preferences.on 'fetch:success', (collection)->
				if not collection.findWhere(name: 'approval')
					collection.add({name: 'approval', value: 0, user_id: AlumNet.current_user.id})
				if not collection.findWhere(name: 'friendship')
					collection.add({name: 'friendship', value: 0, user_id: AlumNet.current_user.id})
				if not collection.findWhere(name: 'friendship_accepted')
					collection.add({name: 'friendship_accepted', value: 0, user_id: AlumNet.current_user.id})
				if not collection.findWhere(name: 'join_group_invitation')
					collection.add({name: 'join_group_invitation', value: 0, user_id: AlumNet.current_user.id})
				if not collection.findWhere(name: 'message')
					collection.add({name: 'message', value: 0, user_id: AlumNet.current_user.id})
				if not collection.findWhere(name: 'join_event')
					collection.add({name: 'join_event', value: 0, user_id: AlumNet.current_user.id})
				if not collection.findWhere(name: 'apply_job_post')
					collection.add({name: 'apply_job_post', value: 0, user_id: AlumNet.current_user.id})
				if not collection.findWhere(name: 'commented_post_edit')
					collection.add({name: 'commented_post_edit', value: 0, user_id: AlumNet.current_user.id})
				if not collection.findWhere(name: 'commented_or_liked_post_comment')
					collection.add({name: 'commented_or_liked_post_comment', value: 0, user_id: AlumNet.current_user.id})

				messages_members = new Notifications.MessagesView
					collection: collection
				layout.messages_members.show(messages_members)

			news_preferences = AlumNet.request("email_preferences:news", AlumNet.current_user.id)
			news_preferences.on 'fetch:success', (collection)->
				if not collection.findWhere(name: 'join_group_request')
					collection.add({name: 'join_group_request', value: 0, user_id: AlumNet.current_user.id})

				news_view = new Notifications.NewsView
					collection: collection
				layout.notifications.show(news_view)

			user_groups = AlumNet.request("membership:groups", AlumNet.current_user.id, {})
			user_groups.on 'fetch:success', (groups_collection)->
				groups_preferences = AlumNet.request("email_preferences:groups", AlumNet.current_user.id)
				groups_preferences.on 'fetch:success', (collection)->
					user_groups.each (model)->
						if not collection.findWhere(group_id: model.get('group_id'))
							collection.add({group_id: model.get('group_id'), value: 0, user_id: AlumNet.current_user.id, group_name: model.get('group').name})

					groups_view = new Notifications.GroupsView
						collection: collection
					layout.groups_digest.show(groups_view)