@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  class Posts.CommentView extends Marionette.ItemView
    template: 'groups/posts/templates/comment'
    className: 'comment'

  class Posts.PostView extends Marionette.CompositeView
    template: 'groups/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post'
    ui:
      'commentInput': '.comment'
    events:
      'keypress .comment': 'commentSend'

    commentSend: (e)->
      e.stopPropagation()
      if e.keyCode == 13
        e.preventDefault()
        data = Backbone.Syphon.serialize(this)
        if data.body != ''
          @trigger 'comment:submit', data
          @ui.commentInput.val('')

    onBeforeRender: ->
      @model.comments.fetch()
      @collection = @model.comments

  class Posts.PostsView extends Marionette.CompositeView
    template: 'groups/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'
    ui:
      'bodyInput': '#body'
    events:
      'click a#js-post-submit': 'submitClicked'

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != ''
        @trigger 'post:submit', data
        @ui.bodyInput.val('')



