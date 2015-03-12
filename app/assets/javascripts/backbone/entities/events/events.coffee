@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Event extends Backbone.Model

    initialize: ->
      unless @isNew()
        @setAttendance()

    setAttendance: ->
      attendance = @get('attendance_info')
      if attendance
        @attendance = new Entities.Attendance attendance
      else
        @attendance = new Entities.Attendance

    getLocation: ->
      city = @get('city')
      country = @get('country')
      address = @get('address')
      [country.text, city.text, address].join(', ')


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

    findEvent: (parent, parent_id, id)->
      evento = new Entities.Event
        id: id
      evento.urlRoot = AlumNet.api_endpoint + "/#{parent}/#{parent_id}/events"
      evento

    newAttendance: ->
      new Entities.Attendance

  AlumNet.reqres.setHandler 'event:new', (parent, parent_id) ->
    API.createEvent(parent, parent_id)

  AlumNet.reqres.setHandler 'event:entities', (parent, parent_id) ->
    API.getEvents(parent, parent_id)

  AlumNet.reqres.setHandler 'event:contacts', (parent, parent_id, event_id) ->
    API.getEventContacts(parent, parent_id, event_id)

  AlumNet.reqres.setHandler 'event:find', (parent, parent_id, id) ->
    API.findEvent(parent, parent_id, id)

  AlumNet.reqres.setHandler 'attendance:new', ->
    API.newAttendance()
