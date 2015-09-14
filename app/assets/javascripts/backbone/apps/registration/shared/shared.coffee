@AlumNet.module 'RegistrationApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->

  class Shared.Sidebar extends Marionette.ItemView
    template: 'registration/shared/templates/sidebar'

    initialize: (options) ->
      document.title = " AlumNet - Registration"
      @step = options.step || ""
      @class = [
        "", "", ""
        "", ""
      ]

      @class[@step - 1] = "--active"
      @registration_steps = options.registration_steps

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

      isVisible: !AlumNet.current_user.isExternal()

      registration_steps: @registration_steps


  API =
    getSidebarView: (registration_steps, step)->
      # Contarle a nelson que las vistas se destruyen. Por lo tanto no se puede usar la misma instancia
      # initializeLayout() if Shared.layout == undefined
      # Shared.layout
      new Shared.Sidebar
        registration_steps: registration_steps
        step: step

  AlumNet.reqres.setHandler 'registration:shared:sidebar', (registration_steps, step) ->
    API.getSidebarView(registration_steps, step)