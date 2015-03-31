@AlumNet.module 'UsersApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    showPosts: (user_id)->
      user = AlumNet.request("user:find", user_id)
      current_user = AlumNet.current_user
      user.on 'find:success', (response, options)->

        layout = AlumNet.request("user:layout", user, 0)
        header = AlumNet.request("user:header", user)

        user.posts.fetch()
        posts = new Posts.PostsView
          current_user: current_user
          model: user
          collection: user.posts

        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(posts)

        # AlumNet.mainRegion.show(posts)
        AlumNet.execute('render:users:submenu')

        posts.on "post:submit", (data)->
          post = AlumNet.request("post:user:new", user.id)
          post.save data,
            wait: true
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
            wait: true
            success: (model, response, options) ->
              # post.comments.fetch()
              postView.collection.add(model, {at: 0})

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
        posts.on "childview:comment:edit", (postView, commentView, value)->
          comment = commentView.model
          comment.save { comment: value }

      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)

