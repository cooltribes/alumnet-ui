@AlumNet.module 'EventsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.EventView extends Marionette.ItemView
    template: 'events/list/templates/event'
    className: 'col-md-4 col-sm-6 col-xs-12'

    templateHelpers: ->
      model = @model
      location: @model.getLocation()
      isPast: @model.isPast()
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
      if status
        if attendance.isNew()
          attrs = { user_id: AlumNet.current_user.id, event_id: @model.id, status: status }
          attendance.save(attrs)
        else
          attendance.set('status', status)
          attendance.save()

  class List.EventsView extends Marionette.CompositeView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'events/list/templates/events_container'
    childView: List.EventView
    childViewContainer: ".main-events-area"

    ui:
      'upcomingEvents':'#js-upcoming-events'
      'pastEvents':'#js-past-events'

    events:
      'click @ui.upcomingEvents': 'listUpcomingEvents'
      'click @ui.pastEvents': 'listPastEvents'

    listUpcomingEvents: (e)->
      e.preventDefault()
      @collection.getUpcoming()

    listPastEvents: (e)->
      e.preventDefault()
      @collection.getPast()
