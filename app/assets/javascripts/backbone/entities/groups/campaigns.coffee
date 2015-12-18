@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Campaign extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups/' + @get('group_id') + '/campaigns/'