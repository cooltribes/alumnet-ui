@AlumNet.module 'EventsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Modal extends Backbone.Modal
    template: 'events/shared/templates/upload_modal'
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
    template: 'events/shared/templates/header'
    templateHelpers: ->
      model = @model
      canEditInformation: @model.userIsAdmin()
      hasInvitation: ->
        if model.get('attendance_info') then true else false
      attendance: ->
        if model.get('attendance_info') then model.get('attendance_info') else false
      buttonAttendance: (id,status) ->
        if(id=="js-"+status.replace('_','-'))
          return 'groupCoverArea__attendanceOptions--option--active'
        else
          console.log id.replace('-','_')+"   jo   js-"+status.replace("-", "")
          return ''


    modelEvents:
      'change:cover': 'coverChanged'

    ui:
      'eventName':'#name'
      'uploadCover':'#js-upload-cover'
      'coverArea':'.groupCoverArea'
      'going': '#js-going'
      'maybe': '#js-maybe'
      'notGoing': '#js-not-going'

    events:
      'click @ui.uploadCover': 'uploadClicked'
      'click @ui.going, @ui.maybe, @ui.notGoing': 'updateAttendance'

    coverChanged: ->
      cover = @model.get('cover')
      @ui.coverArea.css('background-image',"url('#{cover.main}'")

    uploadClicked: (e)->
      e.preventDefault()
      modal = new Shared.Modal
        model: @model
      $('#js-modal-cover-container').html(modal.render().el)

    updateAttendance: (e)->
      $('.groupCoverArea__attendanceOptions--option').removeClass 'groupCoverArea__attendanceOptions--option--active'
      $(e.target).addClass 'groupCoverArea__attendanceOptions--option--active'
      value = $(e.currentTarget).data('value')
      attendance = @model.attendance
      attendance.save {status: value}

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
    initialize: ->
      @current_user = AlumNet.current_user

    templateHelpers: ->

    regions:
      header: '#event-header'
      body: '#event-body'

  API =
    getEventLayout: (model)->
      new Shared.Layout
        model: model

    getEventHeader: (model)->
      new Shared.Header
        model: model

  AlumNet.reqres.setHandler 'event:layout', (model) ->
    API.getEventLayout(model)

  AlumNet.reqres.setHandler 'event:header', (model)->
    API.getEventHeader(model)