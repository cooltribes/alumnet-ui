@AlumNet.module 'HomeApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  # COMMENT VIEW
  class Posts.CommentView extends AlumNet.Shared.Views.CommentView
    template: 'home/posts/templates/comment'
    className: 'groupPost__comment'


  # POST VIEW
  class Posts.PostView extends AlumNet.Shared.Views.PostView
    template: 'home/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-xs-12 col-sm-6 col-md-6'

    initialize: (options)->
      super(options)
      # TODO: Preguntar por esto :rafael
      @model.url = AlumNet.api_endpoint + @model.get('resource_path')
      self = @
      self.collection = new AlumNet.Entities.CommentsCollection
      self.collection.comparator = 'created_at'
      #
      @model.comments.fetch
        success: (collection)->
          if collection.length > 3
            self.collection.add(collection.slice((collection.length-3),collection.length))
            $(self.ui.moreComment).show()
          else
            self.collection.add(collection.models)
            $(self.ui.moreComment).hide()

    onBeforeRender: ->


  # POSTS COLLECTION
  class Posts.PostsView extends AlumNet.Shared.Views.PostsView
    ##model is current user
    template: 'home/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.picture_ids = @picture_ids
      if data.body != ''
        @trigger 'post:submit', data
        @picture_ids = []
        @ui.bodyInput.val('')
        @ui.fileList.html('')
        @ui.videoContainer.html('')
        @ui.tagsInput.select2('val', '')
        @ui.tagging.hide()


  class Posts.Layout extends Marionette.LayoutView
    template: 'home/posts/templates/layout'
    regions:
      banners: '#banners-container'
      posts: '#posts-container'
    initialize: ->


  class Posts.BannerView extends Marionette.ItemView
    template: 'home/posts/templates/_banner'
    className: ->
      if @model.get ("activeSlide")
        return 'item active'
      else
        return 'item'

    modelEvents:
      "change:activeSlide": "activate"

    activate: ->
      $(@el).addClass("active")


  class Posts.BannersView extends Marionette.CompositeView
    template: 'home/posts/templates/banners'
    childView: Posts.BannerView
    childViewContainer: '.carousel-inner'
