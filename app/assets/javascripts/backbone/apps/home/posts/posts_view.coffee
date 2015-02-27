@AlumNet.module 'HomeApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  # COMMENT VIEW
  class Posts.CommentView extends Marionette.ItemView
    template: 'home/posts/templates/comment'
    className: 'groupPost__comment'
    initialize: (options)->
      @current_user = options.current_user
    templateHelpers: ->
      current_user_avatar: @current_user.get('avatar').medium

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
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')

  # POST VIEW
  class Posts.PostView extends Marionette.CompositeView
    template: 'home/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-md-6'
    childViewOptions: ->
      current_user: @current_user
    initialize: (options)->
      @current_user = options.current_user
      @model.url = AlumNet.api_endpoint + @model.get('resource_path')

    templateHelpers: ->
      permissions = @model.get('permissions')
      current_user_avatar: @current_user.get('avatar').medium
      infoLink: @model.infoLink()
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete

    onRender: ->
      view = this
      @ui.bodyPost.editable
        type: 'textarea'
        pk: view.model.id
        title: 'Edit Posts'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.trigger 'post:edit', newValue

    ui:
      'item': '.item'
      'commentInput': '.comment'
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'
      'gotoComment': '.js-goto-comment'
      'textareaComment': 'textarea.comment'
      'editLink': '#js-edit-post'
      'deleteLink': '#js-delete-post'
      'bodyPost': '#js-body-post'

    events:
      'keypress .comment': 'commentSend'
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
      'click .js-goto-comment': 'clickedGotoComment'
      'click @ui.editLink': 'clickedEdit'
      'click @ui.deleteLink': 'clickedDelete'

    commentSend: (e)->
      e.stopPropagation()
      if e.keyCode == 13
        e.preventDefault()
        data = Backbone.Syphon.serialize(this)
        if data.body != ''
          @trigger 'comment:submit', data
          @ui.commentInput.val('')

    clickedEdit: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.bodyPost.editable('toggle')

    clickedDelete: (e)->
      e.stopPropagation()
      e.preventDefault()
      @model.destroy()

    clickedLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'post:like'
    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'post:unlike'
    sumLike:()->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-like').addClass('js-unlike').html('unlike')
    remLike:()->
      val = parseInt(@ui.likeCounter.html()) - 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')
    clickedGotoComment: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.textareaComment.focus()

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
    ##model is current user
    template: 'home/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'
    childViewOptions: ->
      current_user: @model
    templateHelpers: ->
      current_user_avatar: @model.get('avatar').large
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