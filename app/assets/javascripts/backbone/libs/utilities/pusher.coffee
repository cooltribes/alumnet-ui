@AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->
  _.extend AlumNet,
    startPusher: (key, user) ->
      # if window.rails_env != 'production'
      Pusher.log = (message) ->
        window.console.log message  if window.console and window.console.log

      @pusher = new Pusher(key)
      channel = AlumNet.pusher.subscribe("USER-#{user.id}")
      channel.bind 'new_message', (data) =>
        count = user.get('unread_messages_count')
        count++
        user.set('unread_messages_count', count)
        user.messages.fetch()
