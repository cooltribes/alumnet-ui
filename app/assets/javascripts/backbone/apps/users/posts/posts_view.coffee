@AlumNet.module 'UsersApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  # LIKE MODAL
  class Posts.LikesModal extends AlumNet.Shared.Views.LikesModal

  #### COMMENT VIEW
  class Posts.CommentView extends AlumNet.Shared.Views.CommentView
    template: 'users/posts/templates/comment'
    className: 'groupPost__comment'


  #### POST VIEW
  class Posts.PostView extends AlumNet.Shared.Views.PostView
    template: 'users/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-md-6'
    clientHeight: 60


  ###### POST DETAIL
  class Posts.PostDetail extends Posts.PostView
    template: 'users/posts/templates/post_detail'
    className: 'container margin_top_small'


  #### POST COLLECTION
  class Posts.PostsView extends AlumNet.Shared.Views.PostsView
    template: 'users/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.picture_ids = @picture_ids
      if data.body != ''
        @trigger 'post:submit', data
        view = @
        @picture_ids = []
        @ui.bodyInput.val('')
        @ui.fileList.html('')
        @ui.videoContainer.html('')
        @ui.tagsInput.select2('val', '')
        @ui.tagging.hide()
