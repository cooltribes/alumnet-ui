@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.UserPrize extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/' + @get('user_id') + '/prizes'

  class Entities.UserPrizesCollection extends Backbone.Collection
    model: Entities.UserPrize

  API =
    createUserPrize: (attrs)->
      user_prize = new Entities.UserPrize(attrs)
      user_prize.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      user_prize

    getUserPrizes: (user_id)->
      prizes = new Entities.UserPrizesCollection
      prizes.url = AlumNet.api_endpoint + '/users/' + user_id + '/prizes'
      prizes.fetch
        error: (collection, response, options)->
          collection.trigger('fetch:error')
        success: (collection, response, options) ->
          collection.trigger('fetch:success', collection)
      prizes

  AlumNet.reqres.setHandler 'user_prize:create', (attrs) ->
    API.createUserPrize(attrs)