@AlumNet.module 'EventsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    showPosts: (event_id)->
      event = AlumNet.request('event:find', event_id)
      current_user = AlumNet.current_user
      event.on 'find:success', ->
        if event.isClose() && not event.userIsInvited()
          $.growl.error({ message: "You cannot see information on this Event. This is a Closed Event" })
        else if event.isSecret() && not event.userIsInvited()
          AlumNet.trigger('show:error', 404)
        else
          layout = AlumNet.request('event:layout', event, 0)
          header = AlumNet.request('event:header', event)

          #configure the composite view of posts
          event.posts.fetch()
          posts = new Posts.PostsView
            event: event
            model: current_user
            collection: event.posts

          #render each view on your own region
          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(posts)
          AlumNet.execute('render:events:submenu')

      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)

    showPost: (event_id, id)->
      event = AlumNet.request('event:find', event_id)
      post = AlumNet.request('post:find', 'events', event_id, id)
      current_user = AlumNet.current_user
      event.on 'find:success', ->
        if event.isClose() && not event.userIsInvited()
          $.growl.error({ message: "You cannot see information on this Event. This is a Closed Event" })
        else if event.isSecret() && not event.userIsInvited()
          AlumNet.trigger('show:error', 404)
        else
          post.fetch
            success: ->
              postView = new Posts.PostDetail
                event: event
                current_user: current_user
                model: post

              AlumNet.mainRegion.show(postView)
              AlumNet.execute('render:events:submenu')
            error: ->
              AlumNet.trigger('show:error', 404)

      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)