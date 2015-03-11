@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Event extends Backbone.Model

    validation:
      name:
        required: true
      description:
        required: true
      cover:
        required: true

  class Entities.EventsCollection extends Backbone.Collection
    model: Entities.Event

  API =
    createEvent: (parent, parent_id)->
      evento = new Entities.Event
      evento.urlRoot = AlumNet.api_endpoint + "/#{parent}/#{parent_id}/events"
      evento


  AlumNet.reqres.setHandler 'event:new', (parent, parent_id) ->
    API.createEvent(parent, parent_id)
