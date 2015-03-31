@AlumNet.module 'PicturesApp.AlbumList', (AlbumList, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumList.Controller
    showUserAlbums: (layout, user)->
      
      albumCollection = new AlumNet.Entities.AlbumCollection
      albumCollection.url = AlumNet.api_endpoint + '/users/' + layout.model.id + "/albums"
      albumCollection.fetch()

      
      userCanEdit = user.isCurrentUser() # || AlumNet.current_user.isAlumnetAdmin()


      albumsView = new AlbumList.AlbumsView
        collection: albumCollection
        userCanEdit: userCanEdit


      albumsView.on "childview:show:detail", (childview)->  
        AlumNet.trigger "albums:show:detail", layout, childview.model        
        

      albumsView.on "submit:album", (model)->
        albumCollection.create model,
          # wait: true
          success:->
            AlumNet.trigger "albums:show:detail", layout, model        

      
      layout.body.show(albumsView)


    showGroupAlbums: (layout, group)->
      
      #Create the view and show it in the
      albumCollection = new AlumNet.Entities.AlbumCollection
      albumCollection.url = AlumNet.api_endpoint + '/groups/' + group.id + "/albums"
      albumCollection.fetch()

      
      userCanEdit = true #user.isCurrentUser() # || AlumNet.current_user.isAlumnetAdmin()


      albumsView = new AlbumList.AlbumsView
        collection: albumCollection
        userCanEdit: userCanEdit


      albumsView.on "childview:show:detail", (childview)->  
        AlumNet.trigger "albums:show:detail", layout, childview.model        
        

      albumsView.on "submit:album", (model)->
        albumCollection.create model,
          # wait: true        
          success:->
            console.log model
            AlumNet.trigger "albums:show:detail", layout, model        

      
      layout.body.show(albumsView)  

    
