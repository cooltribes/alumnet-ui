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

      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)

    showPost: (user_id, post_id)->
      user = AlumNet.request('user:find', user_id)
      post = AlumNet.request('post:find', 'users', user_id, post_id)
      current_user = AlumNet.current_user
      user.on 'find:success', (response, options)->
        post.fetch
          success: ->
              postView = new Posts.PostDetail
                userModel: user
                current_user: current_user
                model: post

              AlumNet.mainRegion.show(postView)
              AlumNet.execute('render:groups:submenu')
            AlumNet.execute('render:users:submenu')
          error: ->
            AlumNet.trigger('show:error', 404)

      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)
