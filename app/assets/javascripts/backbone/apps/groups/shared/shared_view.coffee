@AlumNet.module 'GroupsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->

  class Shared.CropCoverModal extends Backbone.Modal
    template: 'groups/shared/templates/crop_modal'
    cancelEl: '#js-close-btn'
    events:
      'click #js-crop-btn': 'clickCropAvatar'

    clickCropAvatar: (e)->
      @cropper.crop()

    onShow: ->
      model = @model
      image = @model.get('cover').original + "?#{ new Date().getTime() }"
      options =
        loadPicture: image
        cropUrl: AlumNet.api_endpoint + "/groups/#{@model.id}/cropping"
        doubleZoomControls:false
        rotateControls:false 
        onAfterImgCrop: ->
          model.trigger('change:cover')

      @cropper = new Croppic('croppic', options)

  class Shared.Modal extends Backbone.Modal
    template: 'groups/shared/templates/upload_modal'
    cancelEl: '.js-modal-close'
    preview: ''

    events:
      'click .js-modal-save': 'saveClicked'
      'click .js-modal-crop': 'cropClicked'
      'change #group-cover': 'previewImage'
    
    savePicture: ->
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
          modalCrop = new Shared.CropCoverModal
            model: model
          $('#js-modal-cover-container').html(modalCrop.render().el)
      @model.save {}, options

    cropClicked: (e)->
      e.preventDefault()
      console.log "cropClicked"
      if @preview!=''
        console.log "else"
        @savePicture()
      else        
        console.log "entro"
        modal = new Shared.CropCoverModal
          model: @model
        @destroy()
        $('#js-modal-cover-container').html(modal.render().el)

    previewImage: (e)->
      input = @.$('#group-cover')
      @preview = @.$('#preview-cover')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])

    saveClicked: (e)->
      e.preventDefault()
      console.log "saveClicked"
      @savePicture()
      #@model.trigger('change:cover')

  class Shared.Header extends Marionette.ItemView
    template: 'groups/shared/templates/header'

    initialize: (options)->
      @model = options.model
      document.title = 'AlumNet - '+@model.get("name")

    templateHelpers: ->
      model = @model
      date = new Date()
      canEditInformation: @model.canDo('edit_group')
      userCanInvite: @model.userCanInvite()
      cover_image: @model.get('cover').main + "?#{ new Date().getTime() }"
      cover_style: ->
        cover = model.get('cover')
        if cover.main
          "background-image: url('#{cover.main}?#{date.getTime()}');background-position: #{cover.position};"
        else
          "background-color: #2b2b2b;"

    modelEvents:
      'change:cover': 'coverChanged'

    ui:
      'groupName':'#name'
      'uploadCover':'#js-changeCover'
      'coverArea':'.groupCoverArea'
      'groupCover':'#group-cover'
      'editCover': "#js-editCover"

    events:
      'click @ui.uploadCover': 'uploadClicked'
      'change @ui.groupCover': 'saveCover'
      "click @ui.editCover": "editCover"

    coverChanged: ->
      # cover = @model.get('cover')
      # @ui.coverArea.css('background-image',"url('#{cover.main}?#{ new Date().getTime() }')")
      view = @
      @model.fetch
        success: (model)->
          view.render()

    uploadClicked: (e)->
      e.preventDefault()
      @ui.groupCover.click()
      #modal = new Shared.Modal
      #  model: @model #group
      #$('#js-modal-cover-container').html(modal.render().el)

    coverSaved: true
    editCover: (e)->
      e.preventDefault()
      coverArea = @.$('.groupCoverArea')
      #coverArea = $(@ui.groupCover)
      console.log @coverSaved
      if (@coverSaved)
        $(e.currentTarget).html('<span class="glyphicon glyphicon-edit"></span>  Save cover')
        coverArea.backgroundDraggable()
        coverArea.css('cursor', 'pointer')
        $("#js-crop-label").show()
      else
        coverArea.css('cursor', 'default')
        coverArea.off('mousedown.dbg touchstart.dbg')
        $(window).off('mousemove.dbg touchmove.dbg mouseup.dbg touchend.dbg mouseleave.dbg')
        $(e.currentTarget).html('<span class="glyphicon glyphicon-edit"></span>  Edit cover')
        $("#js-crop-label").hide()
        @model.set "cover_position", coverArea.css('background-position')
        #@model.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
        @model.save
          error: (model, response)->
            console.log response
      @coverSaved=!@coverSaved

    saveCover: (e)->
      e.preventDefault()
      modal = @
      model = @model
      formData = new FormData()
      file = @$('#group-cover')
      formData.append('cover', file[0].files[0])
      formData.append('cover_position', "0px 0px")
      options =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: ->
          model.trigger('change:cover')
          #modal.destroy()
          #modalCrop = new Shared.CropCoverModal
          #  model: model
          #$('#js-modal-cover-container').html(modalCrop.render().el)
      @model.save {}, options

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