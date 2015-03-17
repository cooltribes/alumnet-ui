@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumDetail.Controller
    showAlbum: (layout, album)->
      
      albumView = new AlbumDetail.DetailView
        model: album

      albumView.on "return:to:albums", ()->
        AlumNet.trigger "albums:user:list", layout, layout.model


      layout.body.show(albumView)

    
