@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    showPosts: (group_id)->
      group = AlumNet.request("group:find", group_id)
      group.on 'find:success', (response, options)->
        layout = AlumNet.request("group:layout", group)
        header = AlumNet.request("group:header", group)

        #configure the composite view of posts
        group.posts.fetch()
        posts = new Posts.PostsView
          collection: group.posts

        #render each view on your own region
        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(posts)

        #listen all posts
        posts.on "post:submit", (data)->
          post = AlumNet.request("post:group:new", group.id)
          post.set(data)
          post.save() # Here handle errors
          group.posts.fetch({reset: true})

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
          #here the like is created
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



      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")
