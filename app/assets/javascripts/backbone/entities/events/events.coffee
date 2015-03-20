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
      today > start_date

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

    userIsInvited: ->
      attendance = @get('attendance_info')
      if attendance == null then false else true

    validation:
      name:
        required: true
      description:
        required: true
      cover:
        required: true
      city_id:
        required: true
      country_id:
        required: true
      address:
        required: true

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

    getEventContacts: (parent, parent_id, event_id)->
      contacts = new Entities.EventContacts
      contacts.url = AlumNet.api_endpoint + "/#{parent}/#{parent_id}/events/#{event_id}/contacts"
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

  AlumNet.reqres.setHandler 'event:new', (parent, parent_id) ->
    API.createEvent(parent, parent_id)

  AlumNet.reqres.setHandler 'event:entities', (parent, parent_id) ->
    API.getEvents(parent, parent_id)

  AlumNet.reqres.setHandler 'event:contacts', (parent, parent_id, event_id) ->
    API.getEventContacts(parent, parent_id, event_id)

  AlumNet.reqres.setHandler 'event:find', (id) ->
    API.findEvent(id)

  AlumNet.reqres.setHandler 'attendance:new', ->
    API.newAttendance()
