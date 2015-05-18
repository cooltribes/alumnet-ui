@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumDetail.Controller
    showAlbum: (layout, album)->
      
      albumable = layout.model
      userCanEdit = album.collection.userCanEdit

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
        else if albumable instanceof AlumNet.Entities.Event
          AlumNet.trigger "albums:event:list", layout, albumable


      albumView.on "upload:picture", (data)->
        photosCollection.create data,
          wait: true
          data: data
          contentType: false
          processData: false
          
      albumView.on "submit:album", (data)->        
        # console.log data
        data.save data.attributes,
          # wait: true
          success: (model, response) ->
            
            AlumNet.trigger "albums:show:detail", layout, data
          error: (model, response, options) ->
            console.error response

        console.log data


      layout.body.show(albumView)

    
