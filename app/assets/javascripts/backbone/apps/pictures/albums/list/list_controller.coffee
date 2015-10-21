@AlumNet.module 'PicturesApp.AlbumList', (AlbumList, @AlumNet, Backbone, Marionette, $, _) ->
  class AlbumList.Controller
    showUserAlbums: (layout, user)->
      
      userCanEdit = user.isCurrentUser() # || AlumNet.current_user.isAlumnetAdmin()
      
      albumCollection = new AlumNet.Entities.AlbumCollection
      albumCollection.url = AlumNet.api_endpoint + '/users/' + layout.model.id + "/albums"
      albumCollection.userCanEdit = userCanEdit
      
      albumCollection.fetch()

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

      albumsView.on "childview:submit:album", (childview)-> 
        childview.model.save {},
          success: ()->
            childview.render()
            $.growl.notice({ message: 'Album has been updated successfully' })
        

      
      layout.body.show(albumsView)

    showGroupAlbums: (layout, group)->
      
      #Create the view and show it in the
      userCanEdit = group.get("admin") #true #user.isCurrentUser() # || AlumNet.current_user.isAlumnetAdmin()

      albumCollection = new AlumNet.Entities.AlbumCollection
      albumCollection.url = AlumNet.api_endpoint + '/groups/' + group.id + "/albums"
      albumCollection.userCanEdit = userCanEdit
      
      albumCollection.fetch()

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

    showEventAlbums: (layout, event)->
            
      userCanEdit = event.get("admin") #Calculate permissions

      albumCollection = new AlumNet.Entities.AlbumCollection
      albumCollection.url = AlumNet.api_endpoint + '/events/' + layout.model.id + "/albums"
      albumCollection.userCanEdit = userCanEdit

      albumCollection.fetch()

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

    
