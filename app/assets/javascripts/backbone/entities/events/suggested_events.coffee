@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.SuggestedEventsCollection extends Backbone.Collection
    model: Entities.Event
    url: ->
      AlumNet.api_endpoint + '/me/suggestions/events/'
