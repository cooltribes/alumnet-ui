@AlumNet.module 'EventsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.EventView extends Marionette.ItemView
    template: 'events/list/templates/event'
    className: 'container'

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

    initialize: ->
      @searchUpcomingEvents({})

    ui:
      'upcomingEvents':'#js-upcoming-events'
      'pastEvents':'#js-past-events'
      'searchInput': '#js-search-input'

    events:
      'click @ui.upcomingEvents': 'clickUpcoming'
      'click @ui.pastEvents': 'clickPast'
      'keypress @ui.searchInput': 'searchEvents'

    clickUpcoming: (e)->
      e.preventDefault()
      @searchUpcomingEvents({})
      @clearClass()
      @setActiveClass($(e.currentTarget))

    clickPast: (e)->
      e.preventDefault()
      @searchPastEvents({})
      @clearClass()
      @setActiveClass($(e.currentTarget))

    searchUpcomingEvents: (query)->
      @collection.getUpcoming(query)
      @flag = "upcoming"

    searchPastEvents: (query)->
      @collection.getPast(query)
      @flag = "past"


    searchEvents: (e)->
      if e.which == 13
        unless @ui.searchInput.val() == ""
          query = { name_cont: @ui.searchInput.val() }
        else
          query = {}
        if @flag == "upcoming"
          @searchUpcomingEvents(query)
        else
          @searchPastEvents(query)

    setActiveClass: (target)->
      target.addClass("sortingMenu__item__link sortingMenu__item__link--active")

    clearClass: ()->
      $('#js-upcoming-events, #js-past-events')
      .removeClass("sortingMenu__item__link sortingMenu__item__link--active")
      .addClass("sortingMenu__item__link sortingMenu__item__link")