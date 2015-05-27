@AlumNet.module 'EventsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.EventView extends Marionette.ItemView
    template: 'events/discover/templates/event'
    className: 'eventsTableView margin_bottom_xsmall'

    templateHelpers: ->
      model = @model
      location: @model.getLocation()
      isPast: @model.isPast()
      isOpen: @model.isOpen()
      userCanAttend: @model.userCanAttend()
      select: (value, option)->
        if value == option then "selected" else ""
      attendance_status: ->
        attendance_info = model.get('attendance_info')
        if attendance_info
          attendance_info.status
        else
          null
    ui:
      attendanceStatus: '#attendance-status'

    events:
      'change @ui.attendanceStatus': 'changeAttendanceStatus'

    changeAttendanceStatus: (e)->
      e.preventDefault()
      status = $(e.currentTarget).val()
      attendance = @model.attendance
      if status == 'going' && @model.get('admission_type') == 1 && (attendance.get('status') != 'going' || not attendance.get('status'))
        status = 'pending_payment'
      if status
        if attendance.isNew()
          attrs = { user_id: AlumNet.current_user.id, event_id: @model.id, status: status }
          attendance.save(attrs)
        else
          attendance.set('status', status)
          attendance.save()
      if status=='going'
        $(e.target).css('background-color','#72da9e')
      if status=='pending_payment'
        $(e.target).css('background-color','#f5ac45')
        if(@model.get('admission_type') == 1)
          AlumNet.navigate('events/'+@model.id+'/payment', true)
      if status=='invited'
        $(e.target).css('background-color','#6dc2e9')
      if status=='not_going'
        $(e.target).css('background-color','#ea7952')
      if status=='maybe'
        $(e.target).css('background-color','#f5ac45')

  class Discover.EventsView extends Marionette.CompositeView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'events/discover/templates/events_container'
    childView: Discover.EventView
    childViewContainer: ".main-events-area"
     
    ui:
      'searchInput': '#js-search-input'
      'calendario': '#calendar'

    events:
      'keypress @ui.searchInput': 'searchEvents'
      'click .js-viewtable': 'viewTable'
      'click .js-viewCalendar': 'viewCalendar'

    initialize: ->
      @searchUpcomingEvents({})
      document.title = 'AlumNet - Discover Events'

    searchUpcomingEvents: (query)->
      ui = @ui
      options = 
        success: (collection)-> 
          console.log collection.models.get("start_date")         
          eventsArray = collection.models.map (model) ->
            title: model.get("name")
            description: model.get("description")
            datetime: new Date(model.get("start_date"))
          console.log eventsArray

          $(ui.calendario).eCalendar
            weekDays: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
            months: ['January', 'February', 'March', 'April', 'May', 'June',
              'July', 'August', 'September', 'October', 'November', 'December']
            events: eventsArray

      @collection.getUpcoming(query, options)
      @flag = "upcoming"

    searchEvents: (e)->
      if e.which == 13
        unless @ui.searchInput.val() == ""
          query = { name_cont: @ui.searchInput.val() }
        else
          query = {}
        @searchUpcomingEvents(query)