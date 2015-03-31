@AlumNet.module 'PicturesApp', (PicturesApp, @AlumNet, Backbone, Marionette, $, _) ->
  class PicturesApp.Router extends AlumNet.Routers.Base
    # appRoutes:

  API =
    showAlbum: (layout, album)->
      controller = new PicturesApp.AlbumDetail.Controller
      controller.showAlbum(layout, album)
    
    showUserAlbums: (layout, user)->
      controller = new PicturesApp.AlbumList.Controller
      controller.showUserAlbums(layout, user)

    showGroupAlbums: (layout, user)->
      controller = new PicturesApp.AlbumList.Controller
      controller.showGroupAlbums(layout, user)

  AlumNet.on "albums:show:detail", (layout, album)->    
    API.showAlbum(layout, album)  
  
  AlumNet.on "albums:user:list", (layout, user)->    
    API.showUserAlbums(layout, user)  
  
  AlumNet.on "albums:group:list", (layout, user)->    
    API.showGroupAlbums(layout, user)  


  AlumNet.addInitializer ->
    new PicturesApp.Router
      controller: API
