@AlumNet.module 'PicturesApp', (PicturesApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PicturesApp.Router extends AlumNet.Routers.Base
    # appRoutes:

  API =
    showAlbum: (layout, album)->
      controller = new PicturesApp.AlbumDetail.Controller
      controller.showAlbum(layout, album)
    
    showAlbums: (layout, user)->
      controller = new PicturesApp.AlbumList.Controller
      controller.showAlbums(layout, user)

  AlumNet.on "albums:show:detail", (layout, album)->    
    API.showAlbum(layout, album)  
  
  AlumNet.on "albums:user:list", (layout, user)->    
    API.showAlbums(layout, user)  


  AlumNet.addInitializer ->
    new PicturesApp.Router
      controller: API
