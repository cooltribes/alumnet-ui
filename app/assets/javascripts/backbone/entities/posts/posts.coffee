@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Post extends Backbone.Model

    initialize: ->
      @comments = new Entities.CommentsCollection
      @comments.url = AlumNet.api_endpoint + '/posts/' + @get('id') + '/comments'

      @on 'change', ->
        @comments.url = AlumNet.api_endpoint + '/posts/' + @get('id') + '/comments'

    validation:
      body:
        required: true

  class Entities.PostCollection extends Backbone.Collection
    model: Entities.Post

  API =
    getNewPostForGroup: (group_id)->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + '/groups/' + group_id + '/posts'
      post

    getNewPostForUser: (user_id)->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + '/users/' + user_id + '/posts'
      post

  AlumNet.reqres.setHandler 'post:group:new',(group_id)->
    API.getNewPostForGroup(group_id)

  AlumNet.reqres.setHandler 'post:user:new',(user_id)->
    API.getNewPostForUser(user_id)