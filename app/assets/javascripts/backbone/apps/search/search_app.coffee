@AlumNet.module 'SearchApp', (SearchApp, @AlumNet, Backbone, Marionette, $, _) ->
  
  class SearchApp.Router extends AlumNet.Routers.Base
    appRoutes:      
      "search/:search_term": "showResults"
    
  API =
    showResults: (search_term)->
      controller = new SearchApp.Results.Controller
      controller.show()

  AlumNet.commands.setHandler "search:show:results", (search_term)->
    API.showResults(search_term)


  AlumNet.addInitializer ->
    new SearchApp.Router
      controller: API
