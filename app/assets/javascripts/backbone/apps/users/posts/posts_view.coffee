@AlumNet.module 'UsersApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  #### COMMENT VIEW
  class Posts.CommentView extends Marionette.ItemView
    template: 'users/posts/templates/comment'
    className: 'groupPost__comment'
    initialize: (options)->
      @post = options.post
      @userModel = options.userModel
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
          view.model.save { comment: newValue }
      @ui.commentText.linkify()

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
      view = @
      like = AlumNet.request("like:comment:new", @post.id, @model.id)
      like.save {},
        success: ->
          view.sumLike()

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      unlike = AlumNet.request("unlike:comment:new", @post.id, @model.id)
      unlike.save {},
        success: ->
          view.remLike()

    sumLike:()->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-like').addClass('js-unlike').html('unlike')

    remLike:()->
      val = parseInt(@ui.likeCounter.html()) - 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')

  #### POST VIEW
  class Posts.PostView extends Marionette.CompositeView
    template: 'users/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-md-6'

    initialize: (options)->
      @userModel = options.userModel
      @current_user = options.current_user

    childViewOptions: ->
      post: @model
      userModel: @userModel
      current_user: @current_user

    templateHelpers: ->
      model = @model
      permissions = @model.get('permissions')
      current_user_avatar: @current_user.get('avatar').medium
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete
      pictures_is_odd: (pictures)->
        pictures.length % 2 != 0
      picturesToShow: ->
        if model.get('pictures').length > 5
          _.first(model.get('pictures'), 5)
        else
          model.get('pictures')

    onShow: ->
      pictures = @model.get('pictures')
      if pictures && pictures.length > 1
        container = @ui.picturesContainer
        container.imagesLoaded ->
          container.masonry
            columnWidth: '.item'
            gutter: 1

    onBeforeRender: ->
      @model.comments.fetch()
      @collection = @model.comments

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
          view.model.save { body: newValue }
      @ui.bodyPost.linkify()

    ui:
      'item': '.item'
      'commentInput': '.comment'
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'
      'editLink': '#js-edit-post'
      'deleteLink': '#js-delete-post'
      'bodyPost': '#js-body-post'
      'picturesContainer': '.pictures-container'
      'modalContainer': '.modal-container'

    events:
      'keypress .comment': 'commentSend'
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
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
          view = @
          comment = AlumNet.request("comment:post:new", @model.id)
          comment.save data,
            wait: true
            success: (model, response, options) ->
              view.ui.commentInput.val('')
              view.collection.add(model, {at: 0})

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
      view = @
      like = AlumNet.request("like:post:new", @model.id)
      like.save {},
        success: ->
          view.sumLike()

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      unlike = AlumNet.request("unlike:post:new", @model.id)
      unlike.save {},
        success: ->
          view.remLike()

    sumLike:()->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-like').addClass('js-unlike').html('unlike')

    remLike:()->
      val = parseInt(@ui.likeCounter.html()) - 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')


  ###### POST DETAIL
  class Posts.PostDetail extends Posts.PostView
    template: 'users/posts/templates/post_detail'
    className: 'container-fluid margin_top_small'

  #### POST COLLECTION
  class Posts.PostsView extends Marionette.CompositeView
    template: 'users/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'

    initialize: (options)->
      @current_user = options.current_user
      @picture_ids = []

    childViewOptions: ->
      userModel: @model
      current_user: @current_user

    templateHelpers: ->
      current_user_avatar: @current_user.get('avatar').large

    onShow: ->
      view = @
      uploader = new AlumNet.Utilities.Pluploader('js-add-picture', view).uploader
      uploader.init()

    ui:
      'bodyInput': '#body'
      'timeline': '#timeline'
      'fileList': '#js-filelist'
      'uploadLink': '#upload-picture'

    events:
      'click a#js-post-submit': 'submitClicked'

    submitClicked: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      data.picture_ids = @picture_ids
      if data.body != ''
        view = @
        @picture_ids = []
        @ui.bodyInput.val('')
        @ui.fileList.html('')
        post = AlumNet.request("post:user:new", @model.id)
        post.save data,
          wait: true
          success: (model, response, options) ->
            view.collection.add(model, {at: 0})