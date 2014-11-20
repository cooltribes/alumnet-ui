@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Comment extends Backbone.Model
    validation:
      comment:
        required: true

  class Entities.CommentsCollection extends Backbone.Collection
    model: Entities.Comment

  API =
    getNewCommentForPost: (post_id)->
      comment = new Entities.Comment
      comment.urlRoot = AlumNet.api_endpoint + '/posts/' + post_id + '/comments'
      comment

  AlumNet.reqres.setHandler 'comment:post:new', (post_id)->
    API.getNewCommentForPost(post_id)