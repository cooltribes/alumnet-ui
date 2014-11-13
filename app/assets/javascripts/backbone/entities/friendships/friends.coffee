@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Friend extends Backbone.Model

  class Entities.FriendsCollection extends Backbone.Collection
    model: Entities.Friend

  API =
    getFriends: (user_id)->
      friends = new Entities.FriendsCollection
      friends.url = AlumNet.api_endpoint + '/users/' + user_id + '/friends'
      friends

  AlumNet.reqres.setHandler 'user:friends', (user_id)->
    API.getFriends(user_id)