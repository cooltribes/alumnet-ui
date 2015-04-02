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

    showGroupAlbums: (layout, group)->
      controller = new PicturesApp.AlbumList.Controller
      controller.showGroupAlbums(layout, group)
    
    showEventAlbums: (layout, event)->
      controller = new PicturesApp.AlbumList.Controller
      controller.showEventAlbums(layout, event)

  AlumNet.on "albums:show:detail", (layout, album)->    
    API.showAlbum(layout, album)  
  
  AlumNet.on "albums:user:list", (layout, model)->    
    API.showUserAlbums(layout, model)  
  
  AlumNet.on "albums:group:list", (layout, model)->    
    API.showGroupAlbums(layout, model)  

  AlumNet.on "albums:event:list", (layout, model)->    
    API.showEventAlbums(layout, model)  


  AlumNet.addInitializer ->
    new PicturesApp.Router
      controller: API
