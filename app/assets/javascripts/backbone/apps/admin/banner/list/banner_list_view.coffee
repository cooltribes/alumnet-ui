@AlumNet.module 'AdminApp.BannerList', (BannerList, @AlumNet, Backbone, Marionette, $, _) ->

  class BannerList.Layout extends Marionette.LayoutView
    template: 'admin/banner/list/templates/layout'
    className: 'container'
    regions:
      table: '#list-region'
      create: '#create-region'

  #Vista para crear un banner
  class BannerList.CreateView extends Marionette.ItemView
    template: 'admin/banner/list/templates/createBanner'

    initialize: (options)->
      @collection = options.collection
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    events:
      'change #BannerImg': 'previewImage'
      'click #js-addBanner': 'addBanner'


    addBanner: (e)->
      e.preventDefault()
      view = @
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#BannerImg')
      formData.append('picture', file[0].files[0])
      @model.set(data)
      if @model.isValid(true)
        options_for_save =
          wait: true
          contentType: false
          processData: false
          data: formData
          success: (model, response, options)->
            view.collection.add(model)
        @model.save(formData, options_for_save)
        @render()

    previewImage: (e)->
      input = @.$('#BannerImg')
      preview = @.$('#preview-banner')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])



  #Vista para un banner
  class BannerList.BannerView extends Marionette.ItemView
    template: 'admin/banner/list/templates/banner'

    ui:
      'buttonUp': '#js-move-up'
      'buttonDown':'#js-move-down'
      'uploadBanner':'#js-upload-banner'      

    events:
      'click #js-deleteBanner': 'deleteBanner'
      'click #js-move-up': 'moveUp'
      'click #js-move-down': 'moveDown'
      'click @ui.uploadBanner': 'uploadClicked'
    
    modelEvents:
      'change:banner': 'bannerChanged'


    coverChanged: ->
      # cover = @model.get('cover')
      # @ui.coverArea.css('background-image',"url('#{cover.main}?#{ new Date().getTime() }')")
      view = @
      @model.fetch
        success: (model)->
          view.render()

    uploadClicked: (e)->
      console.log "upload Banner"
      e.preventDefault()
      modal = new BannerList.Modal
        model: @model 
      $('#js-modal-banner-container').html(modal.render().el)

    deleteBanner: (e)->
      e.preventDefault()
      e.stopPropagation()
      resp = confirm("Are you sure?")
      if resp
        @model.destroy()
        
    moveUp: (e)->
      e.preventDefault()
      e.stopPropagation()
      console.log "Up"
      @trigger 'moveBannerDown'


    moveDown: (e)->
      e.preventDefault()
      e.stopPropagation()
      console.log "Down"


  #Vista para lista de banners
  class BannerList.BannerTable extends Marionette.CompositeView
    template: 'admin/banner/list/templates/banner_table'
    childView: BannerList.BannerView
    childViewContainer: "#banners-list"

    initialize: (options) ->
      console.log options



  class BannerList.CropCoverModal extends Backbone.Modal
    template: 'admin/banner/list/templates/crop_modal'
    cancelEl: '#js-close-btn'

    onShow: ->
      model = @model
      image = @model.get('picture').original 
      options =
        loadPicture: image
        cropUrl: AlumNet.api_endpoint + "/banners/#{@model.id}/cropping"
        onAfterImgCrop: ->
          model.trigger('change:banner')

      cropper = new Croppic('croppic', options)    


  class BannerList.Modal extends Backbone.Modal
    template: 'admin/banner/list/templates/upload_modal'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'click .js-modal-crop': 'cropClicked'
      'change #BannerImg': 'previewImage'

    cropClicked: (e)->
      e.preventDefault()
      modal = new BannerList.CropCoverModal
        model: @model
      @destroy()
      $('#js-modal-banner-container').html(modal.render().el)

    previewImage: (e)->
      input = @.$('#BannerImg')
      preview = @.$('#preview-banner')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])


    saveClicked: (e)->
      e.preventDefault()
      modal = @
      model = @model
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      _.forEach data, (value, key, list)->
      file = @$('#BannerImg')
      formData.append('picture', file[0].files[0])
      @model.set(data)
      if @model.isValid(true)
        options =
          wait: true
          contentType: false
          processData: false
          data: formData
          success: ->
            modal.destroy()
      @model.save {}, options
      @model.trigger('change:banner')  
