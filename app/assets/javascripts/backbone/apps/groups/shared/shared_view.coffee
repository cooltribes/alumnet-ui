@AlumNet.module 'GroupsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Modal extends Backbone.Modal
    template: 'groups/shared/templates/upload_modal'
    cancelEl: '.js-modal-close'

    events:
      'click .js-modal-save': 'saveClicked'
      'change #group-cover': 'previewImage'

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
      @ui.coverArea.css('background-image',"url('#{cover.main}'")

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

    regions:
      header: '#group-header'
      body: '#group-body'

  API =
    getGroupLayout: (model)->
      new Shared.Layout
        model: model

    getGroupHeader: (model)->
      new Shared.Header
        model: model

  AlumNet.reqres.setHandler 'group:layout', (model) ->
    API.getGroupLayout(model)

  AlumNet.reqres.setHandler 'group:header', (model)->
    API.getGroupHeader(model)