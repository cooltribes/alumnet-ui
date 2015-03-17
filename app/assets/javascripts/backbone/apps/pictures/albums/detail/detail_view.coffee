@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->
  
  class AlbumDetail.Photo extends Marionette.ItemView
    template: 'pictures/albums/detail/templates/_photo'
    className: 'col-md-4 col-sm-6'

  class AlbumDetail.DetailView extends Marionette.CompositeView
    template: 'pictures/albums/detail/templates/albumDetail'
    childView: AlbumDetail.Photo
    emptyView: AlumNet.Utilities.EmptyView
    emptyViewOptions: 
      message: "There is no pictures here"
    childViewContainer: '.albums-list'

    ui:
      "modalCont": "#js-modal-container"  
      "modalCont": "#js-modal-container"  

    triggers:    
      'click .js-returnAlbums': 'return:to:albums'
      

    # createAlbum: (e)->
    #   e.preventDefault()

    #   album = new AlumNet.Entities.Album

    #   modal = new Album.CreateAlbumModal
    #     model: album       
    #     view: this

    #   @ui.modalCont.html(modal.render().el)  

  