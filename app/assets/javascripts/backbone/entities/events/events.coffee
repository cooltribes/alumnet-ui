@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Event extends Backbone.Model

    initialize: ->
      @posts = new Entities.PostCollection
      @posts.url = AlumNet.api_endpoint + '/events/' + @id + '/posts'
      unless @isNew()
        @setAttendance()

    setAttendance: ->
      attendance = @get('attendance_info')
      if attendance
        @attendance = new Entities.Attendance attendance
      else
        @attendance = new Entities.Attendance

    isPast: ->
      today = moment()
      start_date = moment(@get('start_date'))
      start_date < today

    getLocation: ->
      location = []
      location.push(@get('address')) if @get('address')
      location.push(@get('city').name) if @get('city').name != ""
      location.push(@get('country').name) if @get('country').name != ""
      location.join(', ')

    isOpen: ->
      event_type = @get('event_type')
      event_type.value == 0

    isClose: ->
      event_type = @get('event_type')
      event_type.value == 1

    isSecret: ->
      event_type = @get('event_type')
      event_type.value == 2

    userIsAdmin: ->
      @get('admin')

    userCanAttend: ->
      @get('can_attend')

    userIsInvited: ->
      attendance = @get('attendance_info')
      if attendance == null then false else true

    isPaidAlready: ->
      attendance = @get('attendance_info')
      if attendance.status == 'going' && @get('admission_type') == 1 then true else false

    # return representing string for upload_files value if param "value" is true
    # if "value" is false, return the entire list for use in dropdown, etc.
    uploadFilesText: (value = false)->
      values = [
        {value: 0, text: 'Only administrators'},
        {value: 1, text: 'All members'}
      ]
      if value
        values[ @get("upload_files").text ]
      else
        values

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Event name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Event description is required, must be less than 2048 characters long"
      start_date:
        required: true
      end_date:
        required: true
      cover:
        required: true
      # country_id:
      #   required: true
      #   msg: 'Country is required'
      # city_id:
      #   required: true
      #   msg: 'City is required'

  class Entities.EventsCollection extends Backbone.Collection
    model: Entities.Event
    rows: 6
    page: 1

    initialize: (models, options)->
      @eventable = if options then options.eventable else null
      @eventable_id = if options then options.eventable_id else null

    url: ->
      if @eventable && @eventable_id
        AlumNet.api_endpoint + "/#{@eventable}/#{@eventable_id}" + "/events"
      else
        AlumNet.api_endpoint + '/events'

    getUpcoming:(query, options) ->
      today = moment().format('YYYY-MM-DD')
      query = $.extend({}, query, { start_date_gteq: today })
      data = { q: query }
      options = $.extend({}, options, { data: data })
      @fetch( options )

    getPast:(query) ->
      today = moment().format('YYYY-MM-DD')
      query = $.extend({}, query, { start_date_lt: today })
      @fetch( data: { q: query } )


  class Entities.Attendance extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/attendances'

  class Entities.AttendancesCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/attendances'
    model: Entities.Attendance

    getByStatus: (status, query)->
      query = $.extend({}, query, { status_eq: status })
      @fetch( data: { q: query, event_id: @event_id } )

    getInvited:(query) ->
      query = $.extend({}, query, { status_eq: 0 })
      @fetch( data: { q: query, event_id: @event_id } )

    getGoing:(query) ->
      query = $.extend({}, query, { status_eq: 1 })
      @fetch( data: { q: query, event_id: @event_id } )

    getMaybe:(query) ->
      query = $.extend({}, query, { status_eq: 2 })
      @fetch( data: { q: query, event_id: @event_id } )

    getNotGoing:(query) ->
      query = $.extend({}, query, { status_eq: 3 })
      @fetch( data: { q: query, event_id: @event_id } )

    getPendingPayment:(query) ->
      query = $.extend({}, query, { status_eq: 4 })
      @fetch( data: { q: query, event_id: @event_id } )

  class Entities.EventContact extends Backbone.Model

  class Entities.EventContacts extends Backbone.Collection
    model: Entities.EventContact

  initializeEvents = ->
    Entities.events = new Entities.EventsCollection

  API =
    createEvent: (parent, parent_id)->
      evento = new Entities.Event
      evento.urlRoot = AlumNet.api_endpoint + "/#{parent}/#{parent_id}/events"
      evento

    getEventContacts: (event_id)->
      contacts = new Entities.EventContacts
      contacts.url = AlumNet.api_endpoint + "/events/#{event_id}/contacts"
      contacts

    getEventEntities: (querySearch)->
      initializeEvents() if Entities.events == undefined
      Entities.events.fetch
        data: querySearch
        success: (model, response, options) ->
          console.log response
          Entities.events.trigger('fetch:success')
      Entities.events

    findEvent: (id)->
      evento = new Entities.Event
        id: id
      evento.urlRoot = AlumNet.api_endpoint + "/events"
      evento.fetch
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.setAttendance()
          model.trigger('find:success')
      evento

    newAttendance: ->
      new Entities.Attendance

    getAttendances: (event_id)->
      attendances = new Entities.AttendancesCollection
      attendances.event_id = event_id
      attendances

  AlumNet.reqres.setHandler 'event:new', (parent, parent_id) ->
    API.createEvent(parent, parent_id)

  AlumNet.reqres.setHandler 'event:contacts', (parent, parent_id, event_id) ->
    API.getEventContacts(parent, parent_id, event_id)

  AlumNet.reqres.setHandler 'event:find', (id) ->
    API.findEvent(id)

  AlumNet.reqres.setHandler 'attendance:new', ->
    API.newAttendance()

  AlumNet.reqres.setHandler 'attendance:entities', (event_id)->
    API.getAttendances(event_id)

  AlumNet.reqres.setHandler 'event:entities', (querySearch) ->
    API.getEventEntities(querySearch)