@AlumNet.module 'CompaniesApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  ## MODALS
  class Shared.CropModal extends Backbone.Modal
    template: 'companies/shared/templates/crop_modal'
    cancelEl: '#js-close-btn'
    ui:
      'avatarImagen': "#croppic > img"
      'changeProfilePicture': '#js-change-picture'
    
    events:
      'click #js-crop-btn': 'saveImage'
      'change #profile-avatar': 'previewImage'
      'click @ui.changeProfilePicture': 'changePicture'

    changePicture: (e)->
      e.preventDefault()
      $('#profile-avatar').click()

    @isPreview: false
    previewImage: (e)->
      input = @$('#profile-avatar')
      @isPreview = true
      avatarImagen = $(@ui.avatarImagen)
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          avatarImagen.cropper('replace', e.target.result)
        reader.readAsDataURL(input[0].files[0])

    saveImage: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize this
      avatarImagen = $(@ui.avatarImagen)
      if @isPreview
        if data.avatar != ""
          formData = new FormData()
          file = @$('#profile-avatar')
          formData.append('logo', file[0].files[0])
          company = @model
          esto = @
          #user.profile.url = AlumNet.api_endpoint + '/profiles/' + user.profile.id
          company.save formData,
            wait: true
            data: formData
            contentType: false
            processData: false
            success: (model, response, options)->
              #user.profile.url = user.urlRoot() + user.id + '/profile'
              company.set("logo", response.avatar)
              esto.cropAvatar()
      else
        @cropAvatar()

    cropAvatar: ->
      model = @model
      cropBoxData = $(@ui.avatarImagen).cropper('getData')
      imageData = $(@ui.avatarImagen).cropper('getImageData')
      data =
        imgInitH: imageData.naturalHeight
        imgInitW: imageData.naturalWidth
        imgW: imageData.width
        imgH: imageData.height
        imgX1: cropBoxData.x
        imgY1: cropBoxData.y
        cropW: cropBoxData.width
        cropH: cropBoxData.height
        image: 'logo'
      Backbone.ajax
        url: AlumNet.api_endpoint + "/companies/#{@model.id}/cropping"
        type: "POST"
        data: data
        success: (data) =>
          model.trigger('change:logo')
          #if model.isCurrentUser()
          #  AlumNet.current_user.trigger('change:logo')
        error: (data) =>
          console.log(data)

    templateHelpers: ->
      model = @model
      avatar_url: ->
        model.get('logo').original + "?#{ new Date().getTime() }"

    onShow: ->
      console.log @ui.avatarImagen
      $(@ui.avatarImagen).cropper
        aspectRatio: 1 / 1
        movable: false
        zoomable: false
        rotatable: false
        scalable: false

  class Shared.CropModalOLD extends Backbone.Modal
    template: 'companies/shared/templates/crop_modal'
    cancelEl: '#js-close-btn'    
    events:
      'click #js-crop-btn': 'clickCropAvatar'

    clickCropAvatar: (e)->
      @cropper.crop()
   
    initialize: (options)->
      @uploader = options.uploader

    templateHelpers: ->
      uploader: @uploader

    onShow: ->
      model = @model
      image = if @model.get(@uploader) then AlumNet.urlWithTimestamp(@model.get(@uploader).main) else null
      options =
        loadPicture: image
        cropData: { 'image': @uploader }
        cropUrl: AlumNet.api_endpoint + "/companies/#{@model.id}/cropping"
        doubleZoomControls:false
        rotateControls:false         
        onAfterImgCrop: ->
          model.trigger('change:logo')
      cropper = new Croppic('croppic', options)

  class Shared.LogoModal extends Backbone.Modal
    template: 'companies/shared/templates/logo_modal'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'click .js-modal-crop': 'cropClicked'
      'change #company-logo': 'previewImage'

    cropClicked: (e)->
      e.preventDefault()
      modal = new Shared.CropModal
        model: @model
        uploader: 'logo'
      @destroy()
      $('#js-modal-container').html(modal.render().el)

    previewImage: (e)->
      input = @.$('#company-logo')
      preview = @.$('#preview-logo')
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
      file = @$('#company-logo')
      formData.append('logo', file[0].files[0])
      options =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: ->
          modal.destroy()
      @model.save {}, options
      @model.trigger('change:logo')

  class Shared.CoverModal extends Backbone.Modal
    template: 'companies/shared/templates/cover_modal'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'click .js-modal-crop': 'cropClicked'
      'change #company-cover': 'previewImage'

    cropClicked: (e)->
      e.preventDefault()
      modal = new Shared.CropModal
        model: @model
        uploader: 'cover'
      @destroy()
      $('#js-modal-container').html(modal.render().el)

    previewImage: (e)->
      input = @.$('#company-cover')
      preview = @.$('#preview-cover')
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
      file = @$('#company-cover')
      formData.append('cover', file[0].files[0])
      options =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: ->
          modal.destroy()
      @model.save {}, options
      @model.trigger('change:logo')


  class Shared.Header extends Marionette.ItemView
    template: 'companies/shared/templates/header'

    initialize: ->
      @listenTo(@model, 'change:logo', @renderView)

    templateHelpers: ->
      model = @model
      date = new Date()
      isCompanyAdmin: @model.userIsAdmin()
      logo_url: ->
        if model.get('logo')
          AlumNet.urlWithTimestamp(model.get('logo').main)
      cover_url: ->
        if model.get('cover')
          AlumNet.urlWithTimestamp(model.get('cover').main)
      cover_style: ->
        cover = model.get('cover')
        if cover.main
          "background-image: url('#{cover.main}?#{date.getTime()}');background-position: #{cover.position};"
        else
          "background-color: #2b2b2b;"          

    ui:
      'requestLink':'#js-request-admin-company'
      'editLogo':'#js-edit-logo'
      'name':'#name'    
      'coverArea':'.userCoverArea'  
      'editCover': '#js-editCover'
      'uploadCover': '#js-changeCover'
      'eventCover': '#profile-cover'

    events:
      'click @ui.requestLink': 'requestClicked'
      'click @ui.editLogo': 'editLogoClicked'
      'click @ui.editCover': 'editCover'
      'change @ui.eventCover': 'saveCover'
      'click @ui.uploadCover' : 'uploadClicked'      

    onRender: ->
      model = @model
      @ui.name.editable
        type: "text"
        title: "Enter the name of company"
        validate: (value)->
          if $.trim(value) == ""
            "This field is required"
        success: (response, newValue)->
          model.save({'name': newValue})

    renderView: ->
      view = @
      @model.fetch
        success: ->
          view.render()

    requestClicked: (e)->
      e.preventDefault()
      view = @
      company_admin = AlumNet.request('new:company_admin', @model.id, { user_id: AlumNet.current_user.id })
      company_admin.save {},
        success: (model)->
          view._changeButton()
          $.growl.notice(message: "Your request has been sent to admins.")
        error: (model, response)->
          message = AlumNet.formatErrorsFromApi(response.responseJSON)
          $.growl.error(message: message)

    editLogoClicked: (e)->
      e.preventDefault()
      modal = new Shared.CropModal
        model: @model
      $('#js-modal-container').html(modal.render().el)

    uploadClicked: (e)->
      e.preventDefault()
      @ui.eventCover.click()

    coverSaved: true
    editCover: (e)->
      e.preventDefault()
      coverArea = @.$('.userCoverArea')
      if (@coverSaved)
        $(e.currentTarget).html('<span class="glyphicon glyphicon-edit"></span>  Save cover')
        coverArea.backgroundDraggable()
        coverArea.css('cursor', 'pointer')
      else
        coverArea.css('cursor', 'default')
        coverArea.off('mousedown.dbg touchstart.dbg')
        $(window).off('mousemove.dbg touchmove.dbg mouseup.dbg touchend.dbg mouseleave.dbg')
        $(e.currentTarget).html('<span class="glyphicon glyphicon-edit"></span>  Reposition cover')
        @model.set "cover_position", coverArea.css('background-position')
        #@model.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
        @model.save
          error: (model, response)->
            console.log response
      @coverSaved=!@coverSaved

    saveCover: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize this
      console.log data.cover
      if data.cover != ""
        model = @model
        modal = @
        formData = new FormData()
        file = @$('#profile-cover')
        formData.append('cover', file[0].files[0])
        formData.append('cover_position', "0px 0px")
        @model.save formData,
          wait: true
          data: formData
          contentType: false
          processData: false
          success: ()->
            model.trigger('change:logo')

    editCoverClicked: (e)->
      e.preventDefault()
      modal = new Shared.CoverModal
        model: @model
      $('#js-modal-container').html(modal.render().el)
    
    _changeButton: ()->
      @ui.requestLink.attr("disabled", true)
      @ui.requestLink.text("Waiting for admins response")

  class Shared.Layout extends Marionette.LayoutView
    template: 'companies/shared/templates/layout'

    regions:
      header: '#company-header'
      body: '#company-body'

    initialize: (options) ->
      @tab = options.tab
      @class = ["", "", ""
        "", ""
      ]
      @class[parseInt(@tab)] = "--active"

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

  API =
    getCompanyLayout: (model, tab)->
      new Shared.Layout
        model: model
        tab: tab

    getCompanyHeader: (model)->
      new Shared.Header
        model: model


  AlumNet.reqres.setHandler 'company:layout', (model, tab) ->
    API.getCompanyLayout(model, tab)

  AlumNet.reqres.setHandler 'company:header', (model)->
    API.getCompanyHeader(model)