@AlumNet.module 'PicturesApp.AlbumList', (AlbumList, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumList.Controller
    # showAlbums: (layout, id)->
    showAlbums: (layout, user)->
      
      #Create the view and show it in the
      albumCollection = new AlumNet.Entities.AlbumCollection
      albumCollection.url = AlumNet.api_endpoint + '/users/' + layout.model.id + "/albums"
      # albumCollection.url = AlumNet.api_endpoint + '/users/' + user.id + "/albums"
      albumCollection.fetch()

      albumsView = new AlbumList.AlbumsView
        collection: albumCollection


      albumsView.on "childview:show:detail", (childview)->  
        AlumNet.trigger "albums:show:detail", layout, childview.model        
        

      albumsView.on "create:album", (model)->  
        console.log model
        model.urlRoot = AlumNet.api_endpoint + '/users/' + layout.model.id + "/albums"
        model.save
          success:->
            AlumNet.trigger "albums:show:detail", layout, model        

      
      layout.body.show(albumsView)

    
