@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumDetail.Controller
    showAlbum: (layout, album)->
      
      albumView = new AlbumDetail.DetailView
        model: album


      layout.body.show(albumView)

    
