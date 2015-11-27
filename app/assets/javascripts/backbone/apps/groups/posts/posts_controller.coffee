@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    showPosts: (group_id)->
      checkNewPost = false #flag for new posts
      group = AlumNet.request('group:find', group_id)
      current_user = AlumNet.current_user
      group.on 'find:success', ->
        if group.isClose() && not group.userIsMember()
          #$.growl.error({ message: "You cannot see information on this Group. This is a Closed Group" })
        else if group.isSecret() && not group.userIsMember()
          AlumNet.trigger('show:error', 404)
        else
          layout = AlumNet.request('group:layout', group, 0)
          header = AlumNet.request('group:header', group)

          #configure the composite view of posts
          group.posts.url = AlumNet.api_endpoint + '/groups/' + group_id + '/posts'
          group.posts.page = 1 #initialize page number on first load
          group.posts.fetch
            data: { page: group.posts.page, per_page: group.posts.rows }
            reset: true

          posts = new Posts.PostsView
            model: group
            collection: group.posts

          #render each view on your own region
          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(posts)
          AlumNet.execute('render:groups:submenu')

          posts.on "post:reload", ->
            ++posts.collection.page
            newCollection = AlumNet.request("post:current")
            newCollection.url = AlumNet.api_endpoint + '/groups/'+ group_id + '/posts'
            newCollection.fetch
              data: { page: posts.collection.page, per_page: posts.collection.rows }
              success: (collection)->
                posts.collection.add(collection.models)

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
            post = AlumNet.request('post:group:new', @model.id)
            post.save data,
            success: (model, response, options)->
              checkNewPost = true
              posts.collection.add(model, {at: 0})
              container = $('#timeline')
              container.masonry "reloadItems"

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)

    showPost: (group_id, post_id)->
      group = AlumNet.request('group:find', group_id)
      post = AlumNet.request('post:find', 'groups', group_id, post_id)
      current_user = AlumNet.current_user
      group.on 'find:success', ->
        if group.isClose() && not group.userIsMember()
          $.growl.error({ message: "You cannot see information on this Group. This is a Closed Group" })
        else if group.isSecret() && not group.userIsMember()
          AlumNet.trigger('show:error', 404)
        else
          post.fetch
            success: ->
              postView = new Posts.PostDetail
                postable: group
                model: post

              AlumNet.mainRegion.show(postView)
              AlumNet.execute('render:groups:submenu')
            error: ->
              AlumNet.trigger('show:error', 404)

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)

