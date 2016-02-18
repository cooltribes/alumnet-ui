@AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->
  _.extend AlumNet,
    startPusher: (key, user) ->
      if gon.environment != 'production'
        Pusher.log = (message) ->
          window.console.log message  if window.console and window.console.log

      @pusher = new Pusher(key, {encrypted: true})
      channel = AlumNet.pusher.subscribe("USER-#{user.id}")
      channel.bind 'new_message', (data) =>
        count = user.get('unread_messages_count')
        count++
        user.set('unread_messages_count', count)
        user.messages.fetch
          success: ->
            ion.sound.play("water_droplet_3")
      channel.bind 'new_notification', (data) =>
        count = user.get('unread_notifications_count')
        count++
        user.set('unread_notifications_count', count)
        user.notifications.fetch()
