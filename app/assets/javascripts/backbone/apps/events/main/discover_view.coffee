@AlumNet.module 'EventsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.EventView extends Marionette.ItemView
    template: 'events/main/templates/_event_discover'

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

  class Discover.EmptyView extends Marionette.ItemView
    template: 'events/main/templates/empty_discover'

  class Discover.EventsView extends Marionette.CompositeView
    emptyView: Discover.EmptyView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'events/main/templates/events_container'
    childView: Discover.EventView
    childViewContainer: ".main-events-area"

    ui:
      'calendario': '#calendar'
      'loading': '.throbber-loader'

    events:
      'click .js-viewtable': 'viewTable'
      'click .js-viewCalendar': 'viewCalendar'

    templateHelpers: ()->
      collection = @collection

    initialize: (options)->
      AlumNet.setTitle('Discover Events')

      @parentView = options.parentView
      @collection.search()
      self = @
      @collection.on "fetch:success", () ->
        self.eventsCalendar()

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreEvents')

      $(window).scroll(@loadMoreEvents)

      $("#iconsTypeEvents").removeClass("hide")

    eventsCalendar: ()->
      self = this
      eventsArray = self.eventsMap(self, @collection)
      eventsArray = self.longEvents(self, eventsArray)

      $.each eventsArray, (id,content)->
        if content["duracion"]> 0
          content["datetime"] = content["startime"]

      $(@ui.calendario).eCalendar
        events: eventsArray

    eventsMap: (self, collection)->
      eventsArray = collection.models.map (model) ->
        id: model.get("id")
        title: model.get("name")
        description: model.get("description")
        datetime: self.eventDate(model.get("start_date"),model.get("start_hour"))
        startime: self.eventDate(model.get("start_date"),model.get("start_hour"))
        endtime: self.eventDate(model.get("end_date"),model.get("end_hour"))
        cover: model.get("cover").card
        official: model.get("official")
        duracion: self.duracion(model.get("start_date"),model.get("end_date"))
      return eventsArray

    longEvents: (self, eventsArray) ->
      $.each eventsArray, (id,content)->
        if content["duracion"]> 0
          for eventos in [1 .. content["duracion"]]
            aux = {
              id: content["id"]
              title: content["title"]
              description: content["description"]
              datetime: self.addDay(content["datetime"])
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
      # TODO: Usar plugin moment :diana :daniela
      diff = new Date(end[0]+"/"+end[1]+"/"+end[2]).getTime() - new Date(start[0]+"/"+start[1]+"/"+start[2]).getTime();
      dias = Math.floor(diff / (1000 * 60 * 60 * 24))
      return dias

    remove: ->
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    loadMoreEvents: (e)->
      if @collection.nextPage == null
        @endPagination()
      else
        if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
          @reloadItems()

    reloadItems: ->
      search_options =
        page: @collection.nextPage
        remove: false
        reset: false
      @collection.search_by_last_query(search_options)
