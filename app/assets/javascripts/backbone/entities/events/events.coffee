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
      city = @get('city')
      country = @get('country')
      address = @get('address')
      [address, country.text, city.text].join(', ')

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

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Event name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Event description is required, must be less than 2048 characters"
      start_date:
        required: true
      end_date:
        required: true
      cover:
        required: true
      country_id:
        required: true
        msg: 'Country is required'
      city_id:
        required: true
        msg: 'City is required'

  class Entities.EventsCollection extends Backbone.Collection
    model: Entities.Event

    getUpcoming:(query) ->
      today = moment().format('YYYY-MM-DD')
      query = $.extend({}, query, { start_date_gteq: today })
      @fetch( data: { q: query } )

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

  class Entities.EventContact extends Backbone.Model

  class Entities.EventContacts extends Backbone.Collection
    model: Entities.EventContact

  API =
    createEvent: (parent, parent_id)->
      evento = new Entities.Event
      evento.urlRoot = AlumNet.api_endpoint + "/#{parent}/#{parent_id}/events"
      evento

    getEvents: (parent, parent_id)->
      events = new Entities.EventsCollection
      events.url = AlumNet.api_endpoint + "/#{parent}/#{parent_id}/events"
      events

    getOpenEvents: ()->
      events = new Entities.EventsCollection
      events.url = AlumNet.api_endpoint + "/events"
      events

    getEventContacts: (event_id)->
      contacts = new Entities.EventContacts
      contacts.url = AlumNet.api_endpoint + "/events/#{event_id}/contacts"
      contacts

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

  AlumNet.reqres.setHandler 'event:entities', (parent, parent_id) ->
    API.getEvents(parent, parent_id)

  AlumNet.reqres.setHandler 'event:entities:open', ->
    API.getOpenEvents()

  AlumNet.reqres.setHandler 'event:contacts', (parent, parent_id, event_id) ->
    API.getEventContacts(parent, parent_id, event_id)

  AlumNet.reqres.setHandler 'event:find', (id) ->
    API.findEvent(id)

  AlumNet.reqres.setHandler 'attendance:new', ->
    API.newAttendance()

  AlumNet.reqres.setHandler 'attendance:entities', (event_id)->
    API.getAttendances(event_id)
