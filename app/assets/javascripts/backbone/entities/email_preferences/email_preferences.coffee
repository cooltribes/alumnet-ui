@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.EmailPreference extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/' + @get('user_id') + '/email_preferences'

  class Entities.EmailPreferencesCollection extends Backbone.Collection
    model: Entities.EmailPreference

  API =
    # createUserPrize: (attrs)->
    #   user_prize = new Entities.UserPrize(attrs)
    #   user_prize.save attrs,
    #     error: (model, response, options) ->
    #       model.trigger('save:error', response, options)
    #     success: (model, response, options) ->
    #       model.trigger('save:success', response, options)
    #   user_prize

    getUserPreferences: (user_id)->
      email_preferences = new Entities.EmailPreferencesCollection
      email_preferences.url = AlumNet.api_endpoint + '/users/' + user_id + '/email_preferences'
      email_preferences.fetch
        error: (collection, response, options)->
          collection.trigger('fetch:error')
        success: (collection, response, options) ->
          collection.trigger('fetch:success', collection)
      email_preferences

  AlumNet.reqres.setHandler 'email_preferences:entities', (attrs) ->
    API.getUserPreferences(attrs)