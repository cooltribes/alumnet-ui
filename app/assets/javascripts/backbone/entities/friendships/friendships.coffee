@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Friendship extends Backbone.Model

  class Entities.FriendshipCollection extends Backbone.Collection
    model: Entities.Friendship

  API =
    getSendFriendship: (attrs)->
      friendship = new Entities.Friendship(attrs)
      friendship.urlRoot = AlumNet.api_endpoint + '/friendships/'
      friendship.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      friendship


  AlumNet.reqres.setHandler 'friendship:send', (attrs) ->
    API.getSendFriendship(attrs)