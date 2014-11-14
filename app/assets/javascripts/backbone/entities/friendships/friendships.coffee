@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Friendship extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/friendships/'

  class Entities.FriendshipCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/friendships/'
    model: Entities.Friendship

  API =
    destroyFriendship: (attrs)->
      friendship = new Entities.Friendship(attrs)
      friendship.destroy
        error: (model, response, options) ->
          model.trigger('delete:error', response, options)
        success: (model, response, options) ->
          model.trigger('delete:success', response, options)
      friendship

    sendFriendship: (attrs)->
      friendship = new Entities.Friendship(attrs)
      friendship.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      friendship

    getFriendships: (filter)->
      friendships = new Entities.FriendshipCollection
      friendships.fetch(data: { filter: filter })
      friendships

  AlumNet.reqres.setHandler 'friendship:destroy', (attrs) ->
    API.destroyFriendship(attrs)

  AlumNet.reqres.setHandler 'friendship:request', (attrs) ->
    API.sendFriendship(attrs)

  AlumNet.reqres.setHandler 'friendships:sent', ->
    API.getFriendships('sent')

  AlumNet.reqres.setHandler 'friendships:received', ->
    API.getFriendships('received')