@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.GroupPost extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups/' + @group_id + '/posts'

    initialize: (options) ->
      @group_id = options.group_id

    validation:
      body:
        required: true

  class Entities.GroupPostCollection extends Backbone.Collection
    model: Entities.GroupPost

    url: ->
      AlumNet.api_endpoint + '/groups/' + @group_id + '/posts'

    initialize: (options) ->
      @group_id = options.group_id