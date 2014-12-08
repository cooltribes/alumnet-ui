@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  # COMMENT VIEW
  class Posts.CommentView extends Marionette.ItemView
    template: 'groups/posts/templates/comment'
    className: 'groupPost__comment'
    ui:
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'
    events:
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'

    clickedLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'comment:like'
    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'comment:unlike'
    sumLike:()->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-like').addClass('js-unlike').html('unlike')
    remLike:()->
      val = parseInt(@ui.likeCounter.html()) - 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').html('like')

  # POST VIEW
  class Posts.PostView extends Marionette.CompositeView
    template: 'groups/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-md-6'
    initialize: (options)->
      @group = options.group
      @current_user = options.current_user
    templateHelpers: ->
      userCanComment: @group.userCanComment()
      current_user_avatar: @current_user.get('avatar').medium
    ui:
      'item': '.item'
      'gotoComment': '.js-goto-comment'
      'commentInput': '.comment'
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'
      'textareaComment': 'textarea.comment'
    events:
      'keypress .comment': 'commentSend'
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
      'click .js-goto-comment': 'clickedGotoComment'

    commentSend: (e)->
      e.stopPropagation()
      if e.keyCode == 13
        e.preventDefault()
        data = Backbone.Syphon.serialize(this)
        if data.body != ''
          @trigger 'comment:submit', data
          @ui.commentInput.val('')

    clickedLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'post:like'
    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'post:unlike'
    clickedGotoComment: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.textareaComment.focus()
    sumLike:()->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-like').addClass('js-unlike').html('unlike')
    remLike:()->
      val = parseInt(@ui.likeCounter.html()) - 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').html('like')


    #Init the render of a comment
    # TODO: try to put this code on onAddChild of CompositeView
    onBeforeRender: ->
      @model.comments.fetch()
      @collection = @model.comments
      #subdelegating the events on commentsView to postView
      @on 'childview:comment:like', (commentView) ->
        @trigger 'comment:like', commentView
      @on 'childview:comment:unlike', (commentView) ->
        @trigger 'comment:unlike', commentView

  class Posts.PostsView extends Marionette.CompositeView
    template: 'groups/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'
    childViewOptions: ->
      group: @group
      current_user: @model

    initialize:(options)->
      @group = options.group
    templateHelpers: ->
      userCanPost: @group.userCanPost()

    ui:
      'bodyInput': '#body'
      'timeline': '#timeline'
    events:
      'click a#js-post-submit': 'submitClicked'

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != ''
        @trigger 'post:submit', data
        @ui.bodyInput.val('')