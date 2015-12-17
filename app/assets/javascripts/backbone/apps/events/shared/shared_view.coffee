@AlumNet.module 'EventsApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.CropCoverModal extends Backbone.Modal
    template: 'events/shared/templates/crop_modal'
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
        cropUrl: AlumNet.api_endpoint + "/events/#{@model.id}/cropping"
        doubleZoomControls:false
        rotateControls:false         
        onAfterImgCrop: ->
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
      date = new Date()      
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
      cover_style: ->
        cover = model.get('cover')
        if cover.main
          "background-image: url('#{cover.main}?#{date.getTime()}');background-position: #{cover.position};"
        else
          "background-color: #2b2b2b;"            

    modelEvents:
      'change:cover': 'coverChanged'

    ui:
      'eventName':'#name'
      'uploadCover':'#js-upload-cover'
      'coverArea':'.groupCoverArea'
      'going': '#js-att-going'
      'maybe': '#js-att-maybe'
      'notGoing': '#js-att-not-going'
      "editCover": "#js-editCover"
      'uploadCover': '#js-changeCover'
      'eventCover': '#profile-cover'

    events:
      #'click @ui.uploadCover': 'uploadClicked'
      'click @ui.going, @ui.maybe, @ui.notGoing': 'updateAttendance'
      "click @ui.editCover": "editCover"
      'change @ui.eventCover': 'saveCover'
      'click @ui.uploadCover' : 'uploadClicked'

    coverChanged: ->
      #cover = @model.get('cover')
      #@ui.coverArea.css('background-image',"url('#{cover.main}?#{ new Date().getTime() }')")
      view = @
      @model.fetch
        success: (model)->
          view.render()

    uploadClicked: (e)->
      e.preventDefault()
      @ui.eventCover.click()

    coverSaved: true
    editCover: (e)->
      e.preventDefault()
      coverArea = @.$('.groupCoverArea')
      if (@coverSaved)
        $(e.currentTarget).html('<span class="glyphicon glyphicon-edit"></span>  Save cover')
        coverArea.backgroundDraggable()
        coverArea.css('cursor', 'pointer')
      else
        coverArea.css('cursor', 'default')
        coverArea.off('mousedown.dbg touchstart.dbg')
        $(window).off('mousemove.dbg touchmove.dbg mouseup.dbg touchend.dbg mouseleave.dbg')
        $(e.currentTarget).html('<span class="glyphicon glyphicon-edit"></span> Reposition cover')
        $("#js-crop-label").hide()
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
            model.trigger('change:cover')



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
      model = @model
      admissionType: @model.get('admission_type')
      classOf: (step) =>
        @class[step]

    regions:
      header: '#event-header'
      body: '#event-body'

    ui:->
      'fileICSCalendar': '#js-fileCalendar'
      'calendarGoogle': '#js-googleCalendar'
      'calendarYahoo': '#js-yahooCalendar'

    events: ->
      'click @ui.fileICSCalendar': 'downloadFileICS'
      'click @ui.calendarGoogle': 'googleCalendarEvents'
      'click @ui.calendarYahoo': 'yahooCalendarEvents'

    downloadFileICS:->
      calendar = ics();
      calendar.addEvent(@model.get("name"), @model.get("description"), @model.get("address"), @model.get("start_date")+' '+@model.get("start_hour"), @model.get("end_date")+' '+@model.get("end_hour"));
      calendar.download('Events');

    googleCalendarEvents:->
      text = encodeURIComponent(@model.get("name")) 
      startDate = moment(@model.get("start_date")+" "+@model.get("start_hour")).format('YYYYMMDDTHHmmSS')
      endDate = moment(@model.get("end_date")+" "+@model.get("end_hour")).add('days',1).format('YYYYMMDDTHHmmSS')
      details = encodeURIComponent(@model.get("description"))
      location = encodeURIComponent(@model.get("address")) 
      googleCalendarUrl = 'http://www.google.com/calendar/event?action=TEMPLATE&text=' + text + '&dates=' + startDate + '/' + endDate + '&details=' + details + '&location=' + location
      window.open(googleCalendarUrl, '_blank')

    yahooCalendarEvents:->
      text = encodeURIComponent(@model.get("name")) 
      startDate = moment(@model.get("start_date")+" "+@model.get("start_hour")).format('YYYYMMDDTHHmmSS')      
      endDate = moment(@model.get("end_date")+" "+@model.get("end_hour")).add('days',1).format('YYYYMMDDTHHmmSS')      
      ###endDate = moment(@model.get("end_date")).format('YYYYMMDD')###
      location = encodeURIComponent(@model.get("address"))
      details = encodeURIComponent(@model.get("description"))
      yahooCalendarUrl = 'http://calendar.yahoo.com/?v=60&TITLE=' + text + '&ST=' + startDate + '&ET=' + endDate + '&in_loc=' + location + '&DESC=' + details
      window.open(yahooCalendarUrl, '_blank')

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
