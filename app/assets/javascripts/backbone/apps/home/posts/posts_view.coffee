@AlumNet.module 'HomeApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  # COMMENT VIEW
  class Posts.CommentView extends Marionette.ItemView
    template: 'home/posts/templates/comment'
    className: 'groupPost__comment'
    initialize: (options)->
      @current_user = options.current_user

    templateHelpers: ->
      permissions = @model.get('permissions')
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete

    onRender: ->
      view = this
      @ui.commentText.editable
        type: 'textarea'
        pk: view.model.id
        title: 'Edit Posts'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          view.trigger 'comment:edit', newValue

    ui:
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'
      'editLink': '#js-edit-comment'
      'deleteLink': '#js-delete-comment'
      'commentText': '#js-comment-text'

    events:
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
      'click @ui.editLink': 'clickedEdit'
      'click @ui.deleteLink': 'clickedDelete'

    clickedEdit: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.commentText.editable('toggle')

    clickedDelete: (e)->
      e.stopPropagation()
      e.preventDefault()
      resp = confirm "Are you sure?"
      if resp
        @model.destroy()

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
      pictures_is_odd: (pictures)->
        pictures.length % 2 != 0

    onShow: ->
      pictures = @model.get('pictures')
      if pictures && pictures.length > 1
        container = @ui.picturesContainer
        container.imagesLoaded ->
          container.masonry
            columnWidth: '.item'
            gutter: 1

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
      'picturesContainer': '.pictures-container'
      'modalContainer': '.modal-container'


    events:
      'keypress .comment': 'commentSend'
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
      'click .js-goto-comment': 'clickedGotoComment'
      'click @ui.editLink': 'clickedEdit'
      'click @ui.deleteLink': 'clickedDelete'
      'click .picture-post': 'clickedPicture'

    clickedPicture: (e)->
      e.preventDefault()
      element = $(e.currentTarget)
      id = element.data('id')
      picture = @model.picture_collection.get(id)
      modal = AlumNet.request "picture:modal", picture
      @ui.modalContainer.html(modal.render().el)

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
      resp = confirm "Are you sure?"
      if resp
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
      @on 'childview:comment:edit', (commentView, newValue) ->
        @trigger 'comment:edit', commentView, newValue

  class Posts.PostsView extends Marionette.CompositeView
    ##model is current user
    template: 'home/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'
    initialize: ->
      @picture_ids = []

    childViewOptions: ->
      current_user: @model

    templateHelpers: ->
      current_user_avatar: @model.get('avatar').large

    ui:
      'bodyInput': '#body'
      'timeline': '#timeline'
      'fileList': '#js-filelist'
      'uploadLink': '#upload-picture'
      'postContainer': '#timeline'

    events:
      'click a#js-post-submit': 'submitClicked'

    onShow: ->
      view = @
      uploader = new AlumNet.Utilities.Pluploader('js-add-picture', view).uploader
      uploader.init()

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