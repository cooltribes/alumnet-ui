@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.UserAction extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/' + @get('user_id') + '/actions'

  class Entities.UserActionsCollection extends Backbone.Collection
    model: Entities.UserAction

  API =
    getUserActions: (user_id)->
      actions = new Entities.UserActionsCollection
      actions.url = AlumNet.api_endpoint + '/users/' + user_id + '/actions'
      actions.fetch
        error: (collection, response, options)->
          collection.trigger('fetch:error')
        success: (collection, response, options) ->
          collection.trigger('fetch:success', collection)
      actions

  AlumNet.reqres.setHandler 'user_actions:actions', (user_id) ->
    API.getUserActions(user_id)