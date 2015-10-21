@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Like extends Backbone.Model

  class Entities.LikesCollection extends Backbone.Collection
    model: Entities.Like

  class Entities.UnLike extends Backbone.Model

  API =
    createLikeToPost: (post_id)->
      like = new Entities.Like
      like.urlRoot = AlumNet.api_endpoint + '/posts/' + post_id + "/like"
      like

    createUnLikeToPost: (post_id)->
      unlike = new Entities.UnLike
      unlike.urlRoot = AlumNet.api_endpoint + '/posts/' + post_id + "/unlike"
      unlike

    createLikeToPicture: (picture_id)->
      like = new Entities.Like
      like.urlRoot = AlumNet.api_endpoint + '/pictures/' + picture_id + "/like"
      like

    createUnLikeToPicture: (picture_id)->
      unlike = new Entities.UnLike
      unlike.urlRoot = AlumNet.api_endpoint + '/pictures/' + picture_id + "/unlike"
      unlike

    createLikeToComment: (commentable_id, comment_id, commentable)->
      like = new Entities.Like
      commentable = "posts" if commentable == undefined
      like.urlRoot = AlumNet.api_endpoint + "/#{commentable}/" + commentable_id + "/comments/" + comment_id + "/like"
      like

    createUnLikeToComment: (commentable_id, comment_id, commentable)->
      unlike = new Entities.UnLike
      commentable = "posts" if commentable == undefined
      unlike.urlRoot = AlumNet.api_endpoint + "/#{commentable}/" + commentable_id + "/comments/" + comment_id + "/unlike"
      unlike


  AlumNet.reqres.setHandler 'like:post:new', (post_id) ->
    API.createLikeToPost(post_id)

  AlumNet.reqres.setHandler 'unlike:post:new', (post_id) ->
    API.createUnLikeToPost(post_id)

  AlumNet.reqres.setHandler 'like:picture:new', (picture_id) ->
    API.createLikeToPicture(picture_id)

  AlumNet.reqres.setHandler 'unlike:picture:new', (picture_id) ->
    API.createUnLikeToPicture(picture_id)

  AlumNet.reqres.setHandler 'like:comment:new', (commentable_id, comment_id, commentable) ->
    API.createLikeToComment(commentable_id, comment_id, commentable)

  AlumNet.reqres.setHandler 'unlike:comment:new', (commentable_id, comment_id, commentable) ->
    API.createUnLikeToComment(commentable_id, comment_id, commentable)