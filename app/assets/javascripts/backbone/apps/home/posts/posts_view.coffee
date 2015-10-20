@AlumNet.module 'HomeApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  # LIKE MODAL
  class Posts.LikesModal extends AlumNet.Shared.Views.LikesModal

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
    #childViewOptions: ->
    #  banner: @banner