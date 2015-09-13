@AlumNet.module 'RegistrationApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    registration: (step)->
      # current_step_url = AlumNet.api_endpoint + "/registration/#{step}"

      layoutView = new Main.Layout
        step: step

      AlumNet.mainRegion.show(layoutView)

