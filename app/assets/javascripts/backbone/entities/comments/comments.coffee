@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Comment extends Backbone.Model
    validation:
      comment:
        required: true

    sumLike: ->
      count = @get('likes_count')
      @set('likes_count', count + 1)
      @set('you_like', true)

    remLike: ->
      count = @get('likes_count')
      @set('likes_count', count - 1)
      @set('you_like', false)


  class Entities.CommentsCollection extends Backbone.Collection
    model: Entities.Comment

  API =
    getNewCommentForPost: (post_id)->
      comment = new Entities.Comment
      comment.urlRoot = AlumNet.api_endpoint + '/posts/' + post_id + '/comments'
      comment

    getNewCommentForPicture: (picture_id)->
      comment = new Entities.Comment
      comment.urlRoot = AlumNet.api_endpoint + '/pictures/' + picture_id + '/comments'
      comment

  AlumNet.reqres.setHandler 'comment:post:new', (post_id)->
    API.getNewCommentForPost(post_id)

  AlumNet.reqres.setHandler 'comment:picture:new', (picture_id)->
    API.getNewCommentForPicture(picture_id)