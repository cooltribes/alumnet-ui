@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.EmailPreference extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/' + @get('user_id') + '/email_preferences'

  class Entities.EmailPreferencesCollection extends Backbone.Collection
    model: Entities.EmailPreference

  API =
    getUserPreferences: (user_id, type)->
      email_preferences = new Entities.EmailPreferencesCollection
      email_preferences.url = AlumNet.api_endpoint + '/users/' + user_id + '/email_preferences/' + type
      email_preferences.fetch
        error: (collection, response, options)->
          collection.trigger('fetch:error')
        success: (collection, response, options) ->
          collection.trigger('fetch:success', collection)
      email_preferences

  AlumNet.reqres.setHandler 'email_preferences:messages', (attrs) ->
    API.getUserPreferences(attrs, 'messages')

  AlumNet.reqres.setHandler 'email_preferences:news', (attrs) ->
    API.getUserPreferences(attrs, 'news')