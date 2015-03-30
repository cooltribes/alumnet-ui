@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumDetail.Controller
    showAlbum: (layout, album)->
      
      user = layout.model
      console.log album
      userCanEdit = true #user.isCurrentUser()

      photosCollection = new AlumNet.Entities.PictureCollection     
      photosCollection.url = AlumNet.api_endpoint + '/albums/' + album.id + "/pictures"
      #Associate album to photos collection
      photosCollection.album = album

      photosCollection.fetch()  

      albumView = new AlbumDetail.DetailView
        model: album
        collection: photosCollection
        userCanEdit: userCanEdit

      albumView.on "return:to:albums", ()->
        AlumNet.trigger "albums:user:list", layout, user

      albumView.on "upload:picture", (data)->
        photosCollection.create data,
          wait: true
          data: data
          contentType: false
          processData: false



      layout.body.show(albumView)

    
