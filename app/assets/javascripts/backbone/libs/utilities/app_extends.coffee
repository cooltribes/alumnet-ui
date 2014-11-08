@AlumNet.module 'Utilities', (Utilities, AlumNet, Backbone, Marionette, $, _) ->

  _.extend AlumNet,
    checkRegistrationStatus: (user) ->
      # step_name = user.get 'registration_status'
      # steps = App.request 'signup:steps:entities', step_name
      # unless steps.isActive()
      #   App.commands.execute 'registration:show'
      #   false
