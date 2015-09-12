@AlumNet.module 'CompaniesApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  ## MODALS
  class Shared.CropModal extends Backbone.Modal
    template: 'companies/shared/templates/crop_modal'
    cancelEl: '#js-close-btn'

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
      isCompanyAdmin: @model.userIsAdmin()
      logo_url: ->
        if model.get('logo')
          AlumNet.urlWithTimestamp(model.get('logo').main)
      cover_url: ->
        if model.get('cover')
          AlumNet.urlWithTimestamp(model.get('cover').main)

    ui:
      'requestLink':'#js-request-admin-company'
      'editLogo':'#js-edit-logo'
      'editCover':'#js-edit-cover'
      'name':'#name'      

    events:
      'click @ui.requestLink': 'requestClicked'
      'click @ui.editLogo': 'editLogoClicked'
      'click @ui.editCover': 'editCoverClicked'

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
      modal = new Shared.LogoModal
        model: @model
      $('#js-modal-container').html(modal.render().el)

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