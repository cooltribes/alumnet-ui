@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    showPosts: (group_id)->
      group = AlumNet.request('group:find', group_id)
      current_user = AlumNet.current_user
      group.on 'find:success', ->
        if group.isClose() && not group.userIsMember()
          $.growl.error({ message: "You cannot see information on this Group. This is a Closed Group" })
        else if group.isSecret() && not group.userIsMember()
          AlumNet.trigger('show:error', 404)
        else
          layout = AlumNet.request('group:layout', group, 0)
          header = AlumNet.request('group:header', group)

          #configure the composite view of posts
          group.posts.fetch()
          posts = new Posts.PostsView
            group: group
            model: current_user
            collection: group.posts

          #render each view on your own region
          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(posts)
          AlumNet.execute('render:groups:submenu')

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
                group: group
                current_user: current_user
                model: post

              AlumNet.mainRegion.show(postView)
              AlumNet.execute('render:groups:submenu')
            error: ->
              AlumNet.trigger('show:error', 404)

      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)

