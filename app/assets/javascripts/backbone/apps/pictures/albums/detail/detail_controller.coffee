@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumDetail.Controller
    showAlbum: (layout, album)->
      
      albumable = layout.model
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
        if albumable instanceof AlumNet.Entities.User
          AlumNet.trigger "albums:user:list", layout, albumable
        else if albumable instanceof AlumNet.Entities.Group
          AlumNet.trigger "albums:group:list", layout, albumable


      albumView.on "upload:picture", (data)->
        photosCollection.create data,
          wait: true
          data: data
          contentType: false
          processData: false
          
      albumView.on "submit:picture", (data)->
        console.log data


      layout.body.show(albumView)

    
