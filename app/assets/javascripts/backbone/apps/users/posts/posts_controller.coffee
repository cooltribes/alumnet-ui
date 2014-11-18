@AlumNet.module 'UsersApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    showPosts: (user_id)->
      user = AlumNet.request("user:find", user_id)
      user.on 'find:success', (response, options)->
        user.posts.fetch()
        posts = new Posts.PostsView
          model: user
          collection: user.posts
        AlumNet.mainRegion.show(posts)

        posts.on "post:submit", (data)->
          post = AlumNet.request("post:user:new", user.id)
          post.set(data)
          post.save() # Here handle errors
          user.posts.fetch({reset: true})

        #Listen each post
        posts.on "childview:comment:submit", (postView, data) ->
          post = postView.model
          comment = AlumNet.request("comment:post:new", post.id)
          comment.set(data)
          comment.save() # Here handle errors
          post.comments.fetch({reset: true})

        #Like in post
        posts.on "childview:post:like", (postView) ->
          post =  postView.model
          like = AlumNet.request("like:post:new", post.id)
          like.save {},
            success: ->
              postView.sumLike()
        posts.on "childview:post:unlike", (postView) ->
          post =  postView.model
          unlike = AlumNet.request("unlike:post:new", post.id)
          unlike.save {},
            success: ->
              postView.remLike()

        #Like in comment
        posts.on "childview:comment:like", (postView, commentView) ->
          post = postView.model
          comment = commentView.model
          like = AlumNet.request("like:comment:new", post.id, comment.id)
          like.save {},
            success: ->
              commentView.sumLike()
        posts.on "childview:comment:unlike", (postView, commentView) ->
          post = postView.model
          comment = commentView.model
          unlike = AlumNet.request("unlike:comment:new", post.id, comment.id)
          unlike.save {},
            success: ->
              commentView.remLike()

      user.on 'find:error', (response, options)->
        ##Logic here the user not exists or is not authorizate
        console.log "Error on user fetch"
