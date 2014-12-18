@AlumNet.module 'HeaderApp', (HeaderApp, @AlumNet, Backbone, Marionette, $, _) ->
  HeaderApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "home": "showHeader"
  

  API =
    showHeader: ->
      controller = new HeaderApp.Menu.Controller
      controller.show()
    
    showAdmin: ->
      controller = new HeaderApp.Menu.Controller
      controller.showAdmin()


  AlumNet.addInitializer ->
    new HeaderApp.Router
      controller: API

  AlumNet.addInitializer ->
    API.showHeader()

  AlumNet.commands.setHandler "header:show:admin", ->    
    API.showAdmin()

  AlumNet.commands.setHandler "header:show:regular" , ->    
    API.showHeader()
