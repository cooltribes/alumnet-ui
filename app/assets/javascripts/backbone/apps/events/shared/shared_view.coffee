@AlumNet.module 'EventsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.CropCoverModal extends Backbone.Modal
    template: 'events/shared/templates/crop_modal'
    cancelEl: '#js-close-btn'

    onShow: ->
      model = @model
      image = @model.get('cover').original + "?#{ new Date().getTime() }"
      options =
        loadPicture: image
        cropUrl: AlumNet.api_endpoint + "/events/#{@model.id}/cropping"
        onAfterImgCrop: ->
          console.log model
          model.trigger('change:cover')

      cropper = new Croppic('croppic', options)
      console.log cropper

  class Shared.Modal extends Backbone.Modal
    template: 'events/shared/templates/upload_modal'
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
          model.trigger('change:cover')
          modal.destroy()
      @model.save {}, options

  class Shared.Header extends Marionette.ItemView
    template: 'events/shared/templates/header'

    templateHelpers: ->
      document.title = 'AlumNet - ' + @model.get('name')
      model = @model
      shortname: short_string(@model.get('name'),50)
      canEditInformation: @model.userIsAdmin()
      userCanAttend: @model.userCanAttend()
      isPast: @model.isPast()
      cover_image: @model.get('cover').main + "?#{ new Date().getTime() }"
      hasInvitation: ->
        if model.get('attendance_info') then true else false
      attendance: ->
        if model.get('attendance_info') then model.get('attendance_info') else false
      buttonAttendance: (id, status) ->
        if status
          if id == "js-att-" + status.replace('_','-')
            return 'groupCoverArea__attendanceOptions--option--active'

    modelEvents:
      'change:cover': 'coverChanged'

    ui:
      'eventName':'#name'
      'uploadCover':'#js-upload-cover'
      'coverArea':'.groupCoverArea'
      'going': '#js-att-going'
      'maybe': '#js-att-maybe'
      'notGoing': '#js-att-not-going'

    events:
      'click @ui.uploadCover': 'uploadClicked'
      'click @ui.going, @ui.maybe, @ui.notGoing': 'updateAttendance'

    coverChanged: ->
      #cover = @model.get('cover')
      #@ui.coverArea.css('background-image',"url('#{cover.main}?#{ new Date().getTime() }')")
      view = @
      @model.fetch
        success: (model)->
          view.render()

    uploadClicked: (e)->
      modal = new Shared.Modal
        model: @model
      $('#js-modal-cover-container').html(modal.render().el)

    updateAttendance: (e)->
      $('.groupCoverArea__attendanceOptions--option').removeClass 'groupCoverArea__attendanceOptions--option--active'
      
      value = $(e.currentTarget).data('value')
      if value == 'going' && @model.get('admission_type') == 1
        value = 'pending_payment'
        $('#js-att-pending-payment').addClass 'groupCoverArea__attendanceOptions--option--active'
      else
        $(e.target).addClass 'groupCoverArea__attendanceOptions--option--active'
      attendance = @model.attendance
      if attendance.isNew()
        values = { event_id: @model.id, user_id: AlumNet.current_user.id, status: value }
      else
        values = { status: value }
      attendance.save values
      if(@model.get('admission_type') == 1 && value == 'pending_payment')
        AlumNet.navigate('events/'+@model.id+'/payment', true)

    onRender: ->
      model = this.model
      @ui.eventName.editable
        type: "text"
        pk: model.id
        title: "Enter the name of Event"
        validate: (value)->
          if $.trim(value) == ""
            "this field is required"
        success: (response, newValue)->
          model.save({'name': newValue})


  class Shared.Layout extends Marionette.LayoutView
    template: 'events/shared/templates/layout'
    initialize: (options) ->
      @current_user = AlumNet.current_user
      @tab = options.tab
      @pointsBar = options.pointsBar
      @class = [
        "", "", ""
        "", ""
      ]
      @class[parseInt(@tab)] = "active"

    templateHelpers: ->
      admissionType: @model.get('admission_type')
      classOf: (step) =>
        @class[step]

    regions:
      header: '#event-header'
      body: '#event-body'

  API =
    getEventLayout: (model,tab)->
      new Shared.Layout
        model: model
        tab: tab

    getEventHeader: (model)->
      new Shared.Header
        model: model

  AlumNet.reqres.setHandler 'event:layout', (model,tab) ->
    API.getEventLayout(model,tab)

  AlumNet.reqres.setHandler 'event:header', (model)->
    API.getEventHeader(model)