@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.UserStats extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/admin/users/stats'
