@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.SuggestedUser extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/'

  class Entities.SuggestedUsersCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/me/suggestions/users/'
    model: Entities.SuggestedUser