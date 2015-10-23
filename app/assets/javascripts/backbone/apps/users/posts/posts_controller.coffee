@AlumNet.module 'UsersApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    showPosts: (user_id)->
      user = AlumNet.request("user:find", user_id)
      current_user = AlumNet.current_user
      user.on 'find:success', (response, options)->

        layout = AlumNet.request("user:layout", user, 0)
        header = AlumNet.request("user:header", user)

        user.posts.url = AlumNet.api_endpoint + '/users/' + user_id + '/posts'
        user.posts.page = 1
        user.posts.fetch
          data: { page: user.posts.page, per_page: user.posts.rows }
          reset: true

        posts = new Posts.PostsView
          model: user
          collection: user.posts

        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(posts)

        posts.on "post:reload", ->
          #++posts.collection.page
          # TODO: Preguntar por esto!! :rafael
          newCollection = AlumNet.request("post:current")
          newCollection.url = AlumNet.api_endpoint + '/users/'+ user_id + '/posts'
          newCollection.fetch
            data: { page: ++@collection.page, per_page: @collection.rows }
            success: (collection)->
              if collection.length < collection.rows
                posts.endPagination()
              posts.collection.add(collection.models)

        checkNewPost = false #flag for new posts

        posts.on "add:child", (viewInstance)->
          container = $('#timeline')
          container.imagesLoaded ->
            container.masonry
              itemSelector: '.post'
          if checkNewPost
            container.prepend( $(viewInstance.el) ).masonry 'reloadItems'
            container.imagesLoaded ->
              container.masonry 'layout'
          else
            container.append( $(viewInstance.el) ).masonry 'reloadItems'
          checkNewPost = false

        posts.on "post:submit", (data)->
          post = AlumNet.request("post:user:new", @model.id)
          post.save data,
            wait: true
            success: (model, response, options) ->
              checkNewPost = true
              posts.collection.add(model, {at: 0})
              container = $('#timeline')
              container.masonry "reloadItems"

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
          success: (model, response)->
            postView = new Posts.PostDetail
              postable: user
              model: post

            AlumNet.mainRegion.show(postView)
            AlumNet.execute('render:groups:submenu')
            AlumNet.execute('render:users:submenu')
          error: (model, response)->
            AlumNet.trigger('show:error', response.status)

      user.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)
