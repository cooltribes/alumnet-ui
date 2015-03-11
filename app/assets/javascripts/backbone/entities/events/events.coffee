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
        @attendance = null

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


  API =
    createEvent: (parent, parent_id)->
      evento = new Entities.Event
      evento.urlRoot = AlumNet.api_endpoint + "/#{parent}/#{parent_id}/events"
      evento

    getEvents: (parent, parent_id)->
      events = new Entities.EventsCollection
      events.url = AlumNet.api_endpoint + "/#{parent}/#{parent_id}/events"
      events

  AlumNet.reqres.setHandler 'event:new', (parent, parent_id) ->
    API.createEvent(parent, parent_id)

  AlumNet.reqres.setHandler 'event:entities', (parent, parent_id) ->
    API.getEvents(parent, parent_id)
