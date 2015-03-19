@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumDetail.Controller
    showAlbum: (layout, album)->
      
      photosCollection = new AlumNet.Entities.PictureCollection     
      photosCollection.url = AlumNet.api_endpoint + '/albums/' + album.id + "/pictures"

      photosCollection.fetch()  

      albumView = new AlbumDetail.DetailView
        model: album
        collection: photosCollection

      albumView.on "return:to:albums", ()->
        AlumNet.trigger "albums:user:list", layout, layout.model


      layout.body.show(albumView)

    
