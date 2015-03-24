@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->
  
  class AlbumDetail.EmptyView extends Marionette.ItemView
    template: 'pictures/albums/detail/templates/_empty'
    className: 'col-md-12 text-center'
    ###initialize: (options)->
      console.log options
      @model = options.model

    templateHelpers: ->
      model: @model 
###

  class AlbumDetail.Photo extends Marionette.ItemView
    template: 'pictures/albums/detail/templates/_photo'
    className: 'col-md-3 col-sm-6'

  class AlbumDetail.DetailView extends Marionette.CompositeView
    template: 'pictures/albums/detail/templates/albumDetail'
    childView: AlbumDetail.Photo
    emptyView: AlbumDetail.EmptyView
    emptyViewOptions: ->
      model: @model
    childViewContainer: '.albums-list'

    ui:
      "modalCont": "#js-modal-container"  
      "fileInput": "#picture-file"  

    triggers:    
      'click .js-returnAlbums': 'return:to:albums'
    
    events:    
      'click .js-upload': 'triggerFile'
      'change @ui.fileInput': 'uploadPicture'

    triggerFile: (e)->
      e.preventDefault()
      @ui.fileInput.click()

    uploadPicture: (e)->
      data = Backbone.Syphon.serialize this
      if data.picture != ""          
        formData = new FormData()
        file = @$('#picture-file')
        formData.append('picture', file[0].files[0])           
        @trigger "upload:picture", formData 


    # openModal: (e)->
    #   e.preventDefault()     

    #   modal = new AlumNet.PicturesApp.UploadPicture.Modal   
    #     view: this
    #     collection: @collection

    #   @ui.modalCont.html(modal.render().el)    

    # createAlbum: (e)->
    #   e.preventDefault()

    #   album = new AlumNet.Entities.Album

    #   modal = new Album.CreateAlbumModal
    #     model: album       
    #     view: this

    #   @ui.modalCont.html(modal.render().el)  

  