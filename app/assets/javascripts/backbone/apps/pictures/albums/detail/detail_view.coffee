@AlumNet.module 'PicturesApp.AlbumDetail', (AlbumDetail, @AlumNet, Backbone, Marionette, $, _) ->

  class AlbumDetail.EmptyView extends Marionette.ItemView
    template: 'pictures/albums/detail/templates/_empty'
    className: 'col-md-12 text-center'
    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit

  class AlbumDetail.Photo extends Marionette.ItemView
    template: 'pictures/albums/detail/templates/_photo'
    className: 'col-md-3 col-sm-6'

    ui:
      "modalCont": "#js-modal-container"

    events:
      "click .js-pic-detail": "showDetail"
      'click .js-rmvItem': "removeItem"

    modelEvents:
      'change': "modelChange"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit
      userCanDelete: @model.get("can_delete")

    removeItem: (e)->
      e.preventDefault()
      if confirm("Are you sure you want to delete this photo?")
        @model.destroy
          wait: true

    showDetail: (e)->
      e.preventDefault()

      if @model.get("picture")
        modal = AlumNet.request "picture:modal", @model
        @ui.modalCont.html(modal.render().el)

    modelChange: ()  ->
      @render()


  class AlbumDetail.DetailView extends Marionette.CompositeView
    template: 'pictures/albums/detail/templates/albumDetail'
    childView: AlbumDetail.Photo
    emptyView: AlbumDetail.EmptyView
    childViewOptions: ->
      userCanEdit: @userCanEdit
    emptyViewOptions: ->
      userCanEdit: @userCanEdit
    childViewContainer: '.albums-list'

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      @pictures_ids = []

    templateHelpers: ->
      model = @model

      userCanEdit: @userCanEdit

      getLocation: ->
        model.getLocation()

    ui:
      "modalCont": "#js-modal-container"
      "fileInput": "#picture-file"
      "mainUploadButton": "#js-upload"
      "uploadButtons": ".js-upload"
      "descrption":'#js-album-desc'

    triggers:
      'click .js-returnAlbums': 'return:to:albums'

    events:
      'click .js-edit': 'editAlbum'
      'change @ui.fileInput': 'uploadPicture'

    onRender: ->
      view = this
      @ui.descrption.linkify()

    onShow: ->
      #Init the file uploader
      uploader = new AlumNet.Utilities.PluploaderAlbums($(".js-upload", @.$el).get(), @).uploader
      uploader.init()

    editAlbum: (e)->
      e.preventDefault()

      modal = new AlumNet.PicturesApp.AlbumList.AlbumModalForm
        model: @model
        view: this

      @ui.modalCont.html(modal.render().el)


    uploadPicture: (e)->

      # data = Backbone.Syphon.serialize this
      # if data.picture != ""
      #   formData = new FormData()
      #   file = @$('#picture-file')
      #   formData.append('picture', file[0].files[0])
      #   @trigger "upload:picture", formData


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
