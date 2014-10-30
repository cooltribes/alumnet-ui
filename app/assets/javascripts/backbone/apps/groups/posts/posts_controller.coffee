@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    showPosts: (id)->
      group = AlumNet.request("group:find", id)
      group.on 'find:success', (response, options)->
        layout = AlumNet.request("group:layout", group)
        header = AlumNet.request("group:header", group)
        body = new Posts.PostsView
          collection: group.posts
        group.posts.fetch()
        AlumNet.mainRegion.show(layout)
        layout.header.show(header)
        layout.body.show(body)


      group.on 'find:error', (response, options)->
        ##Logic here the group not exists or is not authorizate
        console.log "Error on group fetch"
        AlumNet.trigger("groups:home")
