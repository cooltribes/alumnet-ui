@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Like extends Backbone.Model

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


  AlumNet.reqres.setHandler 'like:post:new', (post_id) ->
    API.createLikeToPost(post_id)

  AlumNet.reqres.setHandler 'unlike:post:new', (post_id) ->
    API.createUnLikeToPost(post_id)