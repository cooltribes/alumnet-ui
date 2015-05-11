@AlumNet.module 'HomeApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller

    showCurrentUserPosts: ->
      current_user = AlumNet.current_user
      current_user.posts.url = AlumNet.api_endpoint + '/me/posts'
      current_user.posts.fetch()
      posts = new Posts.PostsView
        model: current_user
        collection: current_user.posts
      AlumNet.mainRegion.show(posts)

      AlumNet.execute('render:home:submenu')
   
      posts.on "post:submit", (data)->
        post = AlumNet.request("post:user:new", current_user.id)
        post.save data,
          success: (model, response, options) ->
            posts.collection.add(model, {at: 0})

      posts.on "childview:post:edit", (postView, value)->
        post = postView.model
        post.save { body: value }

      #Listen each post
      posts.on "childview:comment:submit", (postView, data) ->
        post = postView.model
        comment = AlumNet.request("comment:post:new", post.id)
        comment.save data,
          success: (model, response, options) ->
            postView.collection.add(model, {at: postView.collection.length})                      

      #Like in post
      posts.on "childview:post:like", (postView) ->
        post =  postView.model
        like = AlumNet.request("like:post:new", post.id)
        like.save {},
          success: ->
            post.sumLike()
            postView.sumLike()
      posts.on "childview:post:unlike", (postView) ->
        post =  postView.model
        unlike = AlumNet.request("unlike:post:new", post.id)
        unlike.save {},
          success: ->
            post.remLike()
            postView.remLike()

      #Like in comment
      posts.on "childview:comment:like", (postView, commentView) ->
        post = postView.model
        comment = commentView.model
        like = AlumNet.request("like:comment:new", post.id, comment.id)
        like.save {},
          success: (model)->
            comment.sumLike()
            commentView.sumLike()

      posts.on "childview:comment:unlike", (postView, commentView) ->
        post = postView.model
        comment = commentView.model
        unlike = AlumNet.request("unlike:comment:new", post.id, comment.id)
        unlike.save {},
          success: (model)->
            comment.remLike()
            commentView.remLike()

      posts.on "childview:comment:edit", (postView, commentView, value)->
        comment = commentView.model
        comment.save { comment: value }

      bannerCollection = new AlumNet.Entities.BannerCollection
      bannerCollection.url = AlumNet.api_endpoint + '/banners/'
      bannerCollection.fetch()
      console.log bannerCollection
      banners = new Posts.BannersView
        model: current_user
        collection: current_user.bannerCollection

    





