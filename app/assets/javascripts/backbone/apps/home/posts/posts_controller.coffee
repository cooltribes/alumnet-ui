@AlumNet.module 'HomeApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller
    
    showCurrentUserPosts: ->
      #1 crear layout view renderizar en mainRegion
      #2 banner composite
      #3
      AlumNet.execute('render:home:submenu')
      checkNewPost = false
      current_user = AlumNet.current_user
      current_user.posts.url = AlumNet.api_endpoint + '/me/posts?page='+current_user.posts.page+'&per_page='+current_user.posts.rows
      current_user.posts.fetch 
        reset: true

      posts = new Posts.PostsView
        model: current_user
        collection: current_user.posts
                 
      bannerCollection = new AlumNet.Entities.BannerCollection
      bannerCollection.url = AlumNet.api_endpoint + '/banners'
      bannerCollection.fetch
        success: (collection)->
          collection.at(0).set("activeSlide", true)

      bannersView = new Posts.BannersView #compositeView - region 1
        collection: bannerCollection

      layout = new Posts.Layout
      AlumNet.mainRegion.show(layout)
      layout.posts.show(posts)
      layout.banners.show(bannersView) 

      posts.on "post:reload", ->
        ++posts.collection.page
        newCollection = AlumNet.request("post:current")
        newCollection.url = AlumNet.api_endpoint + '/me/posts?page='+posts.collection.page+'&per_page='+posts.collection.rows
        newCollection.fetch
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

      posts.on "render:collection", ->
        console.log "render"

      posts.on "post:submit", (data)->
        post = AlumNet.request("post:user:new", current_user.id)
        post.save data,
          success: (model, response, options) ->
            checkNewPost = true
            posts.collection.add(model, {at: 0})
            container = $('#timeline')
            container.masonry "reloadItems"

      posts.on "childview:post:edit", (postView, value)->
        post = postView.model
        post.save { body: value }

      #Listen each post
      posts.on "childview:comment:submit", (postView, data) ->
        post = postView.model
        comment = AlumNet.request("comment:post:new", post.id)
        comment.save data,
          success: (model, response, options) ->
            postView.collection.add(model, {at: postView.collection.length})                      

      #Like in post
      posts.on "childview:post:like", (postView) ->
        post =  postView.model
        like = AlumNet.request("like:post:new", post.id)
        like.save {},
          success: ->
            post.sumLike()
            postView.sumLike()
      posts.on "childview:post:unlike", (postView) ->
        post =  postView.model
        unlike = AlumNet.request("unlike:post:new", post.id)
        unlike.save {},
          success: ->
            post.remLike()
            postView.remLike()

      #Like in comment
      posts.on "childview:comment:like", (postView, commentView) ->
        post = postView.model
        comment = commentView.model
        like = AlumNet.request("like:comment:new", post.id, comment.id)
        like.save {},
          success: (model)->
            comment.sumLike()
            commentView.sumLike()

      posts.on "childview:comment:unlike", (postView, commentView) ->
        post = postView.model
        comment = commentView.model
        unlike = AlumNet.request("unlike:comment:new", post.id, comment.id)
        unlike.save {},
          success: (model)->
            comment.remLike()
            commentView.remLike()

      posts.on "childview:comment:edit", (postView, commentView, value)->
        comment = commentView.model
        comment.save { comment: value }

      posts.on "childview:comment:collection", (collection)->
        console.log "comment"
        console.log collection

    getData: (page)->
      rows = @collection.rows
      start = page * rows
      end = start + rows
      console.log @collection
      console.log start+" end "+end+" length "+@collection.length
      @collection.slice(start,end)

    





