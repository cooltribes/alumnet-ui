@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.History extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/' + @get('user_id') + '/actions/history'

  class Entities.HistoryCollection extends Backbone.Collection
    model: Entities.History

  API =
    getUserHistory: (user_id)->
      history = new Entities.HistoryCollection
      history.url = AlumNet.api_endpoint + '/users/' + user_id + '/actions/history'
      history.fetch
        error: (collection, response, options)->
          collection.trigger('fetch:error')
        success: (collection, response, options) ->
          collection.trigger('fetch:success', collection)
      history

  AlumNet.reqres.setHandler 'history:history', (user_id) ->
    API.getUserHistory(user_id)