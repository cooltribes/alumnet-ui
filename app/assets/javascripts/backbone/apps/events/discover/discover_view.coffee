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
        $(e.target).removeClass('eventsTableView__status--not_going')
        $(e.target).removeClass('eventsTableView__status--else')
        $(e.target).removeClass('eventsTableView__status--maybe')
        $(e.target).addClass('eventsTableView__status--going')
      if status=='pending_payment'
        $(e.target).removeClass('eventsTableView__status--not_going')
        $(e.target).removeClass('eventsTableView__status--else')
        $(e.target).removeClass('eventsTableView__status--going')
        $(e.target).addClass('eventsTableView__status--maybe')
        if(@model.get('admission_type') == 1)
          AlumNet.navigate('events/'+@model.id+'/payment', true)
      if status=='invited'
        $(e.target).removeClass('eventsTableView__status--not_going')
        $(e.target).removeClass('eventsTableView__status--going')
        $(e.target).removeClass('eventsTableView__status--maybe')
        $(e.target).addClass('eventsTableView__status--else')
      if status=='not_going'
        $(e.target).removeClass('eventsTableView__status--else')
        $(e.target).removeClass('eventsTableView__status--going')
        $(e.target).removeClass('eventsTableView__status--maybe')
        $(e.target).addClass('eventsTableView__status--not_going')
      if status=='maybe'
        $(e.target).removeClass('eventsTableView__status--not_going')
        $(e.target).removeClass('eventsTableView__status--else')
        $(e.target).removeClass('eventsTableView__status--going')
        $(e.target).addClass('eventsTableView__status--maybe')

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
      'submit #js-search-form': 'searchEvents'
      #'keypress @ui.searchInput': 'searchEvents'
      'click .js-viewtable': 'viewTable'
      'click .js-viewCalendar': 'viewCalendar'
      #'click .js-search-input': 'searchCliked'
      #'click .js-search': 'searchEvents'

    initialize: ->
      @searchUpcomingEvents({})
      document.title = 'AlumNet - Discover Events'

    onRender: ->
      seft = this
      eventsArray = seft.eventsMap(seft,@collection)
      eventsArray = seft.longEvents(seft,eventsArray)

      $.each eventsArray, (id,content)->
        if content["duracion"]> 0
          content["datetime"] = content["startime"]
      console.log eventsArray

      $(@ui.calendario).eCalendar
        events: eventsArray

    searchUpcomingEvents: (query)->
      seft = this
      ui = @ui
      @collection.comparator = 'start_date'
      options =
        success: (collection)->
          seft.render()

      @collection.getUpcoming(query, options)
      @flag = "upcoming"

    eventsMap: (seft,collection)->
      eventsArray = collection.models.map (model) ->
        id: model.get("id")
        title: model.get("name")
        description: model.get("description")
        datetime: seft.eventDate(model.get("start_date"),model.get("start_hour"))
        startime: seft.eventDate(model.get("start_date"),model.get("start_hour"))
        endtime: seft.eventDate(model.get("end_date"),model.get("end_hour"))
        cover: model.get("cover").card
        official: model.get("official")
        duracion: seft.duracion(model.get("start_date"),model.get("end_date"))
      return eventsArray

    longEvents: (seft, eventsArray) ->
      $.each eventsArray, (id,content)->
        if content["duracion"]> 0
          for eventos in [1 .. content["duracion"]]
            aux = {
              id: content["id"]
              title: content["title"]
              description: content["description"]
              datetime: seft.addDay(content["datetime"])
              startime: content["startime"]
              endtime: content["endtime"]
              cover: content["cover"]
              official: content["official"]
              duracion: 0
            }
            eventsArray.push(aux)
      return eventsArray

    eventDate: (date,hour)->
      datetime = date.split("-")
      return new Date(datetime[0]+"/"+datetime[1]+"/"+datetime[2]+" "+hour)

    addDay: (date)->
      aux = date
      day = aux.getTime()
      milisegundos = parseInt(24*60*60*1000);
      aux.setTime(day+milisegundos)
      day =  aux.getFullYear().toString()+"/"+(aux.getMonth()+1).toString()+"/"+aux.getDate().toString()
      return new Date(day)

    duracion: (dStart,dEnd)->
      start = dStart.split("-")
      end = dEnd.split("-")
      diff = new Date(end[0]+"/"+end[1]+"/"+end[2]).getTime() - new Date(start[0]+"/"+start[1]+"/"+start[2]).getTime();
      dias = Math.floor(diff / (1000 * 60 * 60 * 24))
      return dias

    searchEvents: (e)->
      e.preventDefault()
      unless @ui.searchInput.val() == ""
        query = { name_cont: @ui.searchInput.val() }
      else
        query = {}
      @searchUpcomingEvents(query)