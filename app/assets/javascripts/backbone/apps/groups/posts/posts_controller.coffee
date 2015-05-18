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
          layout = AlumNet.request('group:layout', group,0)
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

          #listen all posts
          posts.on 'post:submit', (data)->
            post = AlumNet.request('post:group:new', group.id)
            post.save data,
             success: (model, response, options)->
              posts.collection.add(model, {at: 0})

          posts.on "childview:post:edit", (postView, value)->
            post = postView.model
            post.save { body: value }

          posts.on 'join', () ->
            attrs = { group_id: group.get('id'), user_id: current_user.id }
            request = AlumNet.request('membership:create', attrs)
            request.on 'save:success', (response, options)->
              console.log response.responseJSON
              AlumNet.trigger "groups:posts", group.get('id')

            request.on 'save:error', (response, options)->
              console.log response.responseJSON

          #Listen each post
          posts.on 'childview:comment:submit', (postView, data) ->
            post = postView.model
            comment = AlumNet.request('comment:post:new', post.id)
            comment.save data,
              success: (model, response, options)->
                #post.comments.fetch()
                postView.collection.add(model, {at: postView.collection.length})

          #Like in post
          posts.on 'childview:post:like', (postView) ->
            post =  postView.model
            like = AlumNet.request('like:post:new', post.id)
            like.save {},
              success: ->
                postView.sumLike()
          posts.on 'childview:post:unlike', (postView) ->
            post =  postView.model
            unlike = AlumNet.request('unlike:post:new', post.id)
            unlike.save {},
              success: ->
                postView.remLike()

          #Like in comment
          posts.on 'childview:comment:like', (postView, commentView) ->
            post = postView.model
            comment = commentView.model
            like = AlumNet.request('like:comment:new', post.id, comment.id)
            like.save {},
              success: ->
                commentView.sumLike()
          posts.on 'childview:comment:unlike', (postView, commentView) ->
            post = postView.model
            comment = commentView.model
            unlike = AlumNet.request('unlike:comment:new', post.id, comment.id)
            unlike.save {},
              success: ->
                commentView.remLike()
          posts.on "childview:comment:edit", (postView, commentView, value)->
            comment = commentView.model
            comment.save { comment: value }
      group.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)
