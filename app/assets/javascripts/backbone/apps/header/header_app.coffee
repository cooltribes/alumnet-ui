@AlumNet.module 'HeaderApp', (HeaderApp, @AlumNet, Backbone, Marionette, $, _) ->

  API =
    showHeader: ->
      controller = new HeaderApp.Menu.Controller
      controller.show()

  AlumNet.addInitializer ->
    API.showHeader()
