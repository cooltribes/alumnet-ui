@AlumNet.module 'HeaderApp', (HeaderApp, @AlumNet, Backbone, Marionette, $, _) ->
  HeaderApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "home": "showHeader"
      

  API =
    showHeader: ->
      controller = new HeaderApp.Home.Controller
      controller.show()    

  # AlumNet.on "header:home",  ->
  #   AlumNet.navigate("home")
  #   API.showHeader()
  

  AlumNet.addInitializer ->    
    new HeaderApp.Router
      controller: API

  AlumNet.addInitializer ->    
    AlumNet.navigate("home")
    API.showHeader()
    # AlumNet.trigger("registration:profile", {});
  

  # HeaderApp.addInitializer ->        
  #   AlumNet.trigger("header:home", {});
