@AlumNet.module 'FilesApp', (FilesApp, @AlumNet, Backbone, Marionette, $, _) ->
  class FilesApp.Router extends AlumNet.Routers.Base
    # appRoutes:

  API =
    listFolders: (layout, album)->
      controller = new FilesApp.Folders.Controller
      controller.listFolders(layout, album)    

  AlumNet.on "folders:list", (layout, folderable)->    
    API.listFolders(layout, folderable)  
  
  

  AlumNet.addInitializer ->
    new FilesApp.Router
      controller: API
