@AlumNet.module 'GroupsApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->

  ###### COMMENT VIEW
  class Posts.CommentView extends Marionette.ItemView
    template: 'groups/posts/templates/comment'
    className: 'groupPost__comment'

    initialize: (options)->
      @post = options.post
      @group = options.group
      @current_user = options.current_user

    templateHelpers: ->
      permissions = @model.get('permissions')
      userCanComment: @group.userIsMember()
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete
      comment: @model.commentWithLinks()

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
          view.model.save { comment: newValue, markup_comment: newValue }
      @ui.commentText.linkify()

    onShow: ->
      container = $('#timeline')
      container.masonry 'layout'


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
      like = AlumNet.request('like:comment:new', @post.id, @model.id)
      like.save {},
        success: ->
          view.sumLike()

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      unlike = AlumNet.request('unlike:comment:new', @post.id, @model.id)
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

  ###### POST VIEW
  class Posts.PostView extends Marionette.CompositeView
    template: 'groups/posts/templates/post'
    childView: Posts.CommentView
    childViewContainer: '.comments-container'
    className: 'post item col-xs-12 col-sm-6 col-md-6'

    initialize: (options)->
      @group = options.group
      @current_user = options.current_user

    templateHelpers: ->
      model = @model
      permissions = @model.get('permissions')
      userCanComment: @group.userIsMember()
      current_user_avatar: @current_user.get('avatar').medium
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete
      tagsLinks: @model.tagsLinks()
      pictures_is_odd: (pictures)->
        pictures.length % 2 != 0
      picturesToShow: ->
        if model.get('pictures').length > 5
          _.first(model.get('pictures'), 5)
        else
          model.get('pictures')

    childViewOptions: ->
      group: @group
      post: @model
      current_user: @current_user

    onShow: ->
      pictures = @model.get('pictures')
      if pictures && pictures.length > 1
        container = @ui.picturesContainer
        container.imagesLoaded ->
          container.masonry
            columnWidth: '.item'
            gutter: 1

      # Mentions in comments
      @ui.commentInput.mentionsInput
        source: AlumNet.api_endpoint + '/me/friendships/suggestions'

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
      validation = @ytVidId(@ui.bodyPost.html().split(" ").pop())
      if validation
        temp_string = @ui.bodyPost.html()
        @ui.bodyPost.html(temp_string.replace(@ui.bodyPost.html().split(" ").pop(),'<div class="video-container"><iframe width="420" height="315" src="http://www.youtube.com/embed/'+validation+'"></iframe></div>'))
      else
        @ui.bodyPost.linkify()

    ui:
      'item': '.item'
      'gotoComment': '.js-goto-comment'
      'commentInput': '.comment'
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'
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

    ytVidId: (url)->
      url = $.trim(url)
      p = /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$/
      if (url.match(p)) then RegExp.$1 else false

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
          comment = AlumNet.request('comment:post:new', @model.id)
          data.comment = @ui.commentInput.mentionsInput('getRawValue')
          data.markup_comment = @ui.commentInput.mentionsInput('getValue')
          data.user_tags_list = @extractMentions @ui.commentInput.mentionsInput('getMentions')
          comment.save data,
            success: (model, response, options)->
              view.ui.commentInput.val('')
              view.collection.add(model, {at: view.collection.length})

    extractMentions: (mentions)->
      array = []
      _.each mentions, (mention)->
        array.push mention.uid
      array.join(",")

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
      like = AlumNet.request('like:post:new', @model.id)
      like.save {},
        success: ->
          view.sumLike()

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      unlike = AlumNet.request('unlike:post:new', @model.id)
      unlike.save {},
        success: ->
          view.remLike()

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
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')

  ###### POST DETAIL
  class Posts.PostDetail extends Posts.PostView
    template: 'groups/posts/templates/post_detail'
    className: 'container margin_top_small'

  ###### POSTS COLLECTION
  class Posts.PostsView extends Marionette.CompositeView
    template: 'groups/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'
    childViewOptions: ->
      group: @group
      current_user: @model

    initialize:(options)->
      $(window).unbind('scroll');
      _.bindAll(this, 'loadMorePosts');
      @group = options.group
      @picture_ids = []
      $(window).scroll(@loadMorePosts);

    templateHelpers: ->
      userCanPost: @group.userIsMember()
      groupJoinProccess: @group.get('join_proccess')
      userHasMembership: @group.userHasMembership(@model.id)
      groupIsClose: @group.isClose()

    onShow: ->
      view = @
      uploader = new AlumNet.Utilities.Pluploader('js-add-picture', view).uploader
      uploader.init()

      @ui.tagsInput.select2
        placeholder: "Tag a Friend"
        multiple: true
        minimumInputLength: 2
        ajax:
          url: AlumNet.api_endpoint + '/me/friendships/friends'
          dataType: 'json'
          data: (term)->
            q:
              m: 'or'
              profile_first_name_cont: term
              profile_last_name_cont: term
          results: (data, page) ->
            results:
              data
        formatResult: (data)->
          "<img class='flag' src='#{data.avatar.small}'/>" + data.name;
        formatSelection: (data)->
          data.name

    ui:
      'bodyInput': '#body'
      'timeline': '#timeline'
      'fileList': '#js-filelist'
      'uploadLink': '#upload-picture'
      'tagsInput': '#js-user-tags-list'
      'tagging': '.tagging'
      'videoContainer': '#video_container'

    events:
      'click a#js-post-submit': 'submitClicked'
      'click .js-join':'sendJoin'
      'click a#js-add-tags': 'showTagging'
      'keyup @ui.bodyInput': 'checkInput'

    showTagging: (e)->
      e.preventDefault()
      if @ui.tagging.is(":visible")
        @ui.tagsInput.select2('val', '')
        @ui.tagging.hide()
      else
        @ui.tagging.show()

    ytVidId: (url)->
      url = $.trim(url)
      p = /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$/
      if (url.match(p)) then RegExp.$1 else false

    checkInput: (e)->
      validation = @ytVidId( @ui.bodyInput.val().split(" ").pop() )
      if validation
        @ui.videoContainer.html('<img src="https://i.ytimg.com/vi/'+validation+'/hqdefault.jpg" />')

    sendJoin:(e)->
      e.preventDefault()
      group = @group
      attrs = { group_id: group.id, user_id: AlumNet.current_user.id }
      request = AlumNet.request('membership:create', attrs)
      request.on 'save:success', (response, options)->
        AlumNet.trigger "groups:posts", group.id
      request.on 'save:error', (response, options)->
        console.log response.responseJSON

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
        @ui.tagsInput.select2('val', '')
        @ui.tagging.hide()

    loadMorePosts: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'post:reload'


