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

          event.posts.url = AlumNet.api_endpoint + '/events/' + event_id + '/posts?page='+event.posts.page+'&per_page='+event.posts.rows
          event.posts.page = 1 #initialize page number on first load
          event.posts.fetch
            reset: true

          posts = new Posts.PostsView
            model: event
            collection: event.posts

          #render each view on your own region
          AlumNet.mainRegion.show(layout)
          layout.header.show(header)
          layout.body.show(posts)
          #AlumNet.execute('render:events:submenu')

          posts.on "post:reload", ->
            ++posts.collection.page
            newCollection = AlumNet.request("post:current")
            newCollection.url = AlumNet.api_endpoint + '/events/'+ event_id + '/posts?page='+posts.collection.page+'&per_page='+posts.collection.rows
            newCollection.fetch
              success: (collection)->
                posts.collection.add(collection.models)

          checkNewPost = false #flag for new posts

          posts.on "add:child", (viewInstance)->
            container = $('#timeline')
            container.imagesLoaded ->
              container.masonry
                itemSelector: '.post'
            if checkNewPost
              container.prepend( $(viewInstance.el) ).masonry().masonry 'reloadItems'
              container.imagesLoaded ->
                container.masonry().masonry 'layout'
            else
              container.append( $(viewInstance.el) ).masonry().masonry 'reloadItems'
            checkNewPost = false

          posts.on "post:submit", (data)->
            post = AlumNet.request('post:event:new', @model.id)
            post.save data,
            success: (model, response, options)->
              checkNewPost = true
              posts.collection.add(model, {at: 0})
              container = $('#timeline')
              container.masonry().masonry "reloadItems"

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
                postable: event
                model: post

              AlumNet.mainRegion.show(postView)
              #AlumNet.execute('render:events:submenu')
            error: ->
              AlumNet.trigger('show:error', 404)

      event.on 'find:error', (response, options)->
        AlumNet.trigger('show:error', response.status)