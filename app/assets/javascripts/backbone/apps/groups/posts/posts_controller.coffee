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
        posts.on "childview:comment:submit", (childView, data) ->
          post = childView.model
          comment = AlumNet.request("comment:post:new", post.id)
          comment.set(data)
          comment.save() # Here handle errors
          post.comments.fetch({reset: true})
        posts.on "childview:click:like", (childView) ->
          post =  childView.model
          like = AlumNet.request("like:post:new", post.id)
          #here the like is created
          like.save {},
            success: ->
              childView.sumLike()
        posts.on "childview:click:unlike", (childView) ->
          post =  childView.model
          unlike = AlumNet.request("unlike:post:new", post.id)
          #here the like is created
          unlike.save {},
            success: ->
              childView.remLike()


      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")
