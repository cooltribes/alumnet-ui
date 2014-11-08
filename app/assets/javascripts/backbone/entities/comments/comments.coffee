@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Comment extends Backbone.Model
    validation:
      comment:
        required: true

  class Entities.CommentsCollection extends Backbone.Collection
    model: Entities.Comment

  API =
    getNewCommentForPost: (post_id)->
      post = new Entities.Post
      post.urlRoot = AlumNet.api_endpoint + '/posts/' + post_id + '/comments'
      post

  AlumNet.reqres.setHandler 'comment:post:new', (post_id)->
    API.getNewCommentForPost(post_id)