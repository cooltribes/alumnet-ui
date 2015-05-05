@AlumNet.module 'GroupsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->

  class Shared.CropCoverModal extends Backbone.Modal
    template: 'groups/shared/templates/crop_modal'
    cancelEl: '#js-close-btn'

    onShow: ->
      model = @model
      image = @model.get('cover').original
      options =
        loadPicture: image
        cropUrl: AlumNet.api_endpoint + "/groups/#{@model.id}/cropping"
        onAfterImgCrop: ->
          model.trigger('change:cover')

      cropper = new Croppic('croppic', options)

  class Shared.Modal extends Backbone.Modal
    template: 'groups/shared/templates/upload_modal'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'click .js-modal-crop': 'cropClicked'
      'change #group-cover': 'previewImage'

    cropClicked: (e)->
      e.preventDefault()
      modal = new Shared.CropCoverModal
        model: @model
      @destroy()
      $('#js-modal-cover-container').html(modal.render().el)

    previewImage: (e)->
      input = @.$('#group-cover')
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
      file = @$('#group-cover')
      formData.append('cover', file[0].files[0])
      options =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: ->
          modal.destroy()
      @model.save {}, options

  class Shared.Header extends Marionette.ItemView
    template: 'groups/shared/templates/header'
    templateHelpers: ->
      canEditInformation: @model.canDo('edit_group')
      userCanInvite: @model.userCanInvite()
      cover_image: @model.get('cover').main + "?#{ new Date().getTime() }"

    modelEvents:
      'change:cover': 'coverChanged'

    ui:
      'groupName':'#name'
      'uploadCover':'#js-upload-cover'
      'coverArea':'.groupCoverArea'

    events:
      'click @ui.uploadCover': 'uploadClicked'

    coverChanged: ->
      cover = @model.get('cover')
      @ui.coverArea.css('background-image',"url('#{cover.main}?#{ new Date().getTime() }')")

    uploadClicked: (e)->
      e.preventDefault()
      modal = new Shared.Modal
        model: @model #group
      $('#js-modal-cover-container').html(modal.render().el)

    onRender: ->
      model = this.model
      @ui.groupName.editable
        type: "text"
        pk: model.id
        title: "Enter the name of Group"
        validate: (value)->
          if $.trim(value) == ""
            "this field is required"
        success: (response, newValue)->
          model.save({'name': newValue})


  class Shared.Layout extends Marionette.LayoutView
    template: 'groups/shared/templates/layout'
    initialize: ->
      @current_user = AlumNet.current_user
 

    templateHelpers: ->
      canEditInformation: @model.canDo('edit_group')
      userCanInvite: @model.userCanInvite()
      userIsMember: @model.userIsMember()
      groupIsClose: @model.isClose()

    events:
      "click #groupMenuList li":"menuClicked"

    menuClicked: (e) ->
     $('.groupMenu__link').removeClass "groupMenu__link--active"
     $(e.target).closest('a').removeClass "groupMenu__link--active"

    regions:
      header: '#group-header'
      body: '#group-body'

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
    getGroupLayout: (model, tab)->
      new Shared.Layout
        model: model
        tab: tab

    getGroupHeader: (model)->
      new Shared.Header
        model: model

  AlumNet.reqres.setHandler 'group:layout', (model,tab) ->
    API.getGroupLayout(model,tab)

  AlumNet.reqres.setHandler 'group:header', (model)->
    API.getGroupHeader(model)