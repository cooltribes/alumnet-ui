@AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->
  _.extend AlumNet,
    startPusher: (key) ->
      # if window.rails_env != 'production'
      Pusher.log = (message) ->
        window.console.log message  if window.console and window.console.log

      @pusher = new Pusher(key)
      # channel = AlumNet.pusher.subscribe('groups')
      # channel.bind 'create', (data) =>
      #   console.log data
      # channel = AlumNet.pusher.subscribe("_#{profile_id}")
