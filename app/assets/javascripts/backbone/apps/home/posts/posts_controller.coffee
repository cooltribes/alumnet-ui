@AlumNet.module 'HomeApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.Controller

    showCurrentUserPosts: ->
      #1 crear layout view renderizar en mainRegion
      #2 banner composite
      #3
      #AlumNet.execute('render:home:submenu')
      checkNewPost = false
      current_user = AlumNet.current_user
      current_user.posts.url = AlumNet.api_endpoint + '/me/posts'
      current_user.posts.fetch
        data: { page: current_user.posts.page, per_page: current_user.posts.rows }
        reset: true
        success: ->
          $('.lazy').lazyload
            skip_invisible : true,
            effect : "fadeIn",
            threshold : 100,
            failure_limit : 10
          $('img.lazy').load ->
            console.log 'image'
            console.log this
            console.log this.height
            console.log this.width
            $('#timeline').masonry
              itemSelector: '.post'
            #this.height = this.height
            #this.width = this.width
      current_user.posts.page = 1

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
      AlumNet.footerRegion.empty()
      layout.posts.show(posts)
      layout.banners.show(bannersView)

      posts.on "post:reload", ->
        self = @
        newCollection = AlumNet.request("post:current")
        newCollection.url = AlumNet.api_endpoint + '/me/posts'
        newCollection.fetch
          data: { page: ++@collection.page, per_page: @collection.rows }
          success: (collection)->
            posts.collection.add(collection.models)
            self.reload = true
            if collection.length < collection.rows
              posts.endPagination()

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

      # posts.on "render:collection", ->

      posts.on "post:submit", (data)->
        post = AlumNet.request("post:user:new", current_user.id)
        post.save data,
          success: (model, response, options) ->
            checkNewPost = true
            posts.collection.add(model, {at: 0})
            container = $('#timeline')
            container.masonry().masonry "reloadItems"

    getData: (page)->
      rows = @collection.rows
      start = page * rows
      end = start + rows
      @collection.slice(start,end)
