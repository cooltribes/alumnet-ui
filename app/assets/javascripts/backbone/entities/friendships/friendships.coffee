@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Friendship extends Backbone.Model

  class Entities.FriendshipCollection extends Backbone.Collection
    model: Entities.Friendship
    rows: 15
    page: 1
    querySearch: {}

  API =
    destroyCurrentUserFriendship: (attrs)->
      friendship = new Entities.Friendship(attrs)
      friendship.urlRoot = AlumNet.api_endpoint + '/me/friendships'
      friendship.destroy
        error: (model, response, options) ->
          model.trigger('delete:error', response, options)
        success: (model, response, options) ->
          model.trigger('delete:success', response, options)
      friendship

    requestCurrentUserFriendship: (attrs)->
      friendship = new Entities.Friendship(attrs)
      friendship.urlRoot = AlumNet.api_endpoint + '/me/friendships'
      friendship.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      friendship

    getCurrentUserFriendship: (filter)->
      friendships = new Entities.FriendshipCollection
      friendships.url = AlumNet.api_endpoint + '/me/friendships'
      friendships

    friendsCurrentUserFriendship: ->
      friendships = new Entities.FriendshipCollection
      friendships.url = AlumNet.api_endpoint + '/me/friendships/friends'
      friendships

    getUserFriends: (id)->
      friendships = new Entities.FriendshipCollection
      friendships.url = AlumNet.api_endpoint + "/users/#{id}/friendships/friends"
      friendships

    getUserMutual: (id)->
      friendships = new Entities.FriendshipCollection
      friendships.url = AlumNet.api_endpoint + "/users/#{id}/friendships/commons"
      friendships


  AlumNet.reqres.setHandler 'current_user:friendship:destroy', (attrs) ->
    API.destroyCurrentUserFriendship(attrs)

  AlumNet.reqres.setHandler 'current_user:friendship:request', (attrs) ->
    API.requestCurrentUserFriendship(attrs)

  AlumNet.reqres.setHandler 'current_user:friendships:get', (filter) ->
    API.getCurrentUserFriendship(filter)

  AlumNet.reqres.setHandler 'current_user:friendships:friends', ->
    API.friendsCurrentUserFriendship()

  AlumNet.reqres.setHandler 'user:friendships:friends', (id)->
    API.getUserFriends(id)

  AlumNet.reqres.setHandler 'user:friendships:mutual', (id)->
    API.getUserMutual(id)
