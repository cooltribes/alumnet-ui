@AlumNet.module 'HeaderApp', (HeaderApp, @AlumNet, Backbone, Marionette, $, _) ->

  API =
    showHeader: ->
      controller = new HeaderApp.Menu.Controller
      controller.show()

    showAdmin: ->
      controller = new HeaderApp.Menu.Controller
      controller.showAdmin()

    showExternal: ->
      controller = new HeaderApp.Menu.Controller
      controller.showExternal()

  AlumNet.addInitializer ->
    API.showHeader()

  AlumNet.commands.setHandler "header:show:admin", ->
    API.showAdmin()

  AlumNet.commands.setHandler "header:show:regular" , ->
    API.showHeader()

  AlumNet.commands.setHandler "header:show:external" , ->
    API.showExternal()