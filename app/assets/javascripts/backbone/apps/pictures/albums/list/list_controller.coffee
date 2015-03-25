@AlumNet.module 'PicturesApp.AlbumList', (AlbumList, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumList.Controller
    # showAlbums: (layout, id)->
    showAlbums: (layout, user)->
      
      #Create the view and show it in the
      albumCollection = new AlumNet.Entities.AlbumCollection
      albumCollection.url = AlumNet.api_endpoint + '/users/' + layout.model.id + "/albums"
      # albumCollection.url = AlumNet.api_endpoint + '/users/' + user.id + "/albums"
      albumCollection.fetch()

      
      userCanEdit = user.isCurrentUser() # || AlumNet.current_user.isAlumnetAdmin()


      albumsView = new AlbumList.AlbumsView
        collection: albumCollection
        userCanEdit: userCanEdit


      albumsView.on "childview:show:detail", (childview)->  
        AlumNet.trigger "albums:show:detail", layout, childview.model        
        

      albumsView.on "create:album", (model)->  
        # model.urlRoot = AlumNet.api_endpoint + '/users/' + layout.model.id + "/albums"
        # model.save
        albumCollection.create model,
          success:->
            console.log model
            AlumNet.trigger "albums:show:detail", layout, model        

      
      layout.body.show(albumsView)

    
