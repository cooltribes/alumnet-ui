@AlumNet.module 'UsersApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  #### COMMENT VIEW
  class Posts.CommentView extends AlumNet.Shared.Views.CommentView
    className: 'groupPost__comment'


  #### POST VIEW
  class Posts.PostView extends AlumNet.Shared.Views.PostView
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
    childView: Posts.PostView
    childViewContainer: '.posts-container'

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.picture_ids = @picture_ids
      data.body = @ui.bodyInput.mentionsInput('getRawValue')
      data.markup_body = @ui.bodyInput.mentionsInput('getValue')
      mentions = @extractMentions @ui.bodyInput.mentionsInput('getMentions')
      data.user_tags_list = @joinMentionsWithTags(mentions, data.user_tags_list)
      if data.body != ''
        @trigger 'post:submit', data
        view = @
        @picture_ids = []
        @ui.bodyInput.val('')
        @ui.fileList.html('')
        @ui.videoContainer.html('')
        @ui.tagsInput.select2('val', '')
        @ui.tagging.hide()
