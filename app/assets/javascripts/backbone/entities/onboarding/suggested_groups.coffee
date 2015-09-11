@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.SuggestedGroup extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups/'

  class Entities.SuggestedGroupsCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/me/suggestions/groups/'
    model: Entities.SuggestedGroup