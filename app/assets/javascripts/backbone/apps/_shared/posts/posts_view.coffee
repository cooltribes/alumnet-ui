@AlumNet.module 'Shared.Views', (Views, @AlumNet, Backbone, Marionette, $, _) ->
  #
  # COMMENT VIEW
  #
  class Views.CommentView extends Marionette.ItemView
    template: '_shared/posts/templates/comment'
    initialize: (options)->
      @postView = options.postView
      @postable = options.postable

    templateHelpers: ->
      model = @model
      today = moment()
      createFormat = moment(@model.get('created_at'))
      permissions = @model.get('permissions')
      dayPassed: today.diff(createFormat,'days')
      getLocationUser: @model.getUserLocation()
      userCanComment: true
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete
      comment: @model.commentWithLinks()
      showDropdownOptions: ->
        permissions.canDelete || permissions.canEdit
     
    onRender: ->
      if AlumNet.current_user.id != @model.get('user').id
        self = @
        @$('#userPopover'+@model.id).popover
          container: 'body'
          html: true
          placement: 'bottom'
          trigger: 'hover'
          template: '<div class="popover previewPopover" role="tooltip"><div class="arrow" style="display:none"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'
          content: ->
            self.$("#contentPopover"+self.model.id).removeClass("hide")

      view = @
      @ui.commentText.editable
        type: 'textarea'
        inputclass: 'comment-editable'
        pk: view.model.id
        title: 'Edit Posts'
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        display: (value, response)->
          $(@).html view.model.commentWithLinks()
        success: (response, newValue)->
          $textarea = view.$('.comment-editable')
          newValues = {
            comment: $textarea.mentionsInput('getRawValue')
            markup_comment: $textarea.mentionsInput('getValue')
            user_tags_list: view.extractMentions($textarea.mentionsInput('getMentions'))
          }
          view.model.save(newValues)

      @ui.commentText.on 'shown', (e, editable) ->
        content = view.model.get('markup_comment') || view.model.get('comment')
        editable.input.$input.val content

      @ui.commentText.linkify()

    onShow: ->
      container = $('#timeline')
      container.masonry 'layout'

    ui: ->
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'
      'editLink': '#js-edit-comment'
      'deleteLink': '#js-delete-comment'
      'commentText': '#js-comment-text'

    events: ->
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
      'click @ui.editLink': 'clickedEdit'
      'click @ui.deleteLink': 'clickedDelete'
      'click .js-popover': 'hidePopover'

    extractMentions: (mentions)->
      array = []
      _.each mentions, (mention)->
        array.push mention.uid
      array.join(",")

    clickedEdit: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.commentText.editable('toggle')
      @$('.comment-editable').mentionsInput
        source: AlumNet.api_endpoint + '/me/friendships/suggestions'

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
      post = @postView.model
      comment = @model
      like = AlumNet.request("like:comment:new", post.id, comment.id)
      like.save {},
        success: (model)->
          comment.sumLike()
          view.sumLike()

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      post = @postView.model
      comment = @model
      unlike = AlumNet.request("unlike:comment:new", post.id, comment.id)
      unlike.save {},
        success: (model)->
          comment.remLike()
          view.remLike()

    sumLike:()->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-like').addClass('js-unlike').
        html('<span class="glyphicon glyphicon-thumbs-down"></span> Unlike')

    remLike:()->
      val = parseInt(@ui.likeCounter.html()) - 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')

    hidePopover: ->
      @$("#userPopover"+@model.id).popover('hide');


  #
  # POST VIEW
  # @postable is the model of the parent view.
  #

  class Views.PostView extends Marionette.CompositeView
    childView: Views.CommentView
    childViewContainer: '.comments-container'

    getTemplate: ->
      if @model.get('post_type') == 'share'
        '_shared/posts/templates/share'
      else
        '_shared/posts/templates/post'

    childViewOptions: ->
      postView: @
      postable: @postable

    initialize: (options)->
      @postsView = options.postsView
      if @postsView
        @postable = @postsView.model
      else if options.postable
        @postable = options.postable
      else
        @postable = null

      @postPictures = @model.get('pictures')

      self = @
      self.collection = new AlumNet.Entities.CommentsCollection
      self.collection.comparator = 'created_at'

      @model.comments.fetch
        success: (collection)->
          if collection.length > 3
            self.collection.add(collection.slice((collection.length-3),collection.length))
            $(self.ui.moreComment).show()
          else
            self.collection.add(collection.models)
            $(self.ui.moreComment).hide()

    templateHelpers: ->
      view = @
      model = @model
      permissions = @model.get('permissions')
      today = moment()
      createFormat = moment(@model.get('created_at'))
      getLocationUser: @model.getUserLocation()
      dayPassed: today.diff(createFormat,'days')
      userCanComment: true
      showInfoLink: false
      canShare: permissions.canShare
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete
      showDropdownOptions: ->
        permissions.canDelete || permissions.canEdit
      current_user_avatar: AlumNet.current_user.get('avatar').medium
      infoLink: @model.infoLink()
      tagsLinks: @model.tagsLinks()
      likesLinks: @model.firstLikeLinks()
      restLikeLink: @model.restLikeLink()
      commentsCount: @model.comments.length

      pictures_is_odd: (pictures)->
        pictures.length % 2 != 0

      picturesToShow: ->
        if view.postPictures.length > 5
          _.first(view.postPictures, 5)
        else
          view.postPictures

    onShow: ->
      self = @
      if @postPictures && @postPictures.length > 1
        container = @ui.picturesContainer
        container.imagesLoaded ->
          container.masonry
            columnWidth: '.item'
            gutter: 1

      # Autosize
      @ui.commentInput.autoResize(onResize: -> setTimeout(self.reloadMasonry, 400))

      # Mentions in comments
      @ui.commentInput.mentionsInput
        source: AlumNet.api_endpoint + '/me/friendships/suggestions'

      if @model.get('post_type') == 'share'
        content = @model.getModelContent()
        contentView = new AlumNet.Shared.Views.ContentView
          model: content
          postsView: @postsView
        @$('.content-container').html(contentView.render().el)


    reloadMasonry: ->
      $('#timeline').masonry()

    onRender: ->
      $('[data-toggle="tooltip"]').tooltip
        html:true

      if AlumNet.current_user.id != @model.get('user').id
        self = @
        @$('#userPopover'+@model.id).popover
          container: 'body'
          html: true
          placement: 'bottom'
          trigger: 'hover'
          template: '<div class="popover previewPopover" role="tooltip"><div class="arrow" style="display:none"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'
          content: ->
            self.$("#contentPopover"+self.model.id).removeClass("hide")

      view = @
      @ui.bodyPost.editable
        type: 'textarea'
        pk: view.model.id
        title: 'Edit Posts'
        emptytext: ''
        toggle: 'manual'
        validate: (value)->
          if $.trim(value) == ''
            'this field is required'
        success: (response, newValue)->
          post = view.model
          post.save { body: newValue }
          validation = view.ytVidId(newValue.split(" ").pop())
          if validation
            temp_string = newValue
            $(this).html(temp_string.replace(newValue.split(" ").pop(),'<div class="video-container"><iframe width="420" height="315" src="http://www.youtube.com/embed/'+validation+'"></iframe></div>'))

      validation = @ytVidId(@ui.bodyPost.html().split(" ").pop())
      if validation
        temp_string = @ui.bodyPost.html()
        @ui.bodyPost.html(temp_string.replace(@ui.bodyPost.html().split(" ").pop(),'<div class="video-container"><iframe width="420" height="315" src="http://www.youtube.com/embed/'+validation+'"></iframe></div>'))
      else
        @ui.bodyPost.linkify()

    ui: ->
      'item': '.item'
      'commentInput': '.comment'
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'
      'gotoComment': '.js-goto-comment'
      'editLink': '#js-edit-post'
      'deleteLink': '#js-delete-post'
      'bodyPost': '#js-body-post'
      'picturesContainer': '.pictures-container'
      'modalContainer': '.modal-container'
      'moreComment':'#js-load-more'
      'likesLinks':'.js-like-links'
      'options':'.js-options'

    events: ->
      'keypress .comment': 'commentSend'
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
      'click .js-goto-comment': 'clickedGotoComment'
      'click @ui.editLink': 'clickedEdit'
      'click @ui.deleteLink': 'clickedDelete'
      'click .picture-post': 'clickedPicture'
      'click @ui.moreComment': 'loadMore'
      'click .js-show-likes': 'showLikes'
      'click .js-share-post': 'showShare'
      'click .js-popover': 'hidePopover'

    showShare: (e)->
      e.preventDefault()
      modal = new AlumNet.Shared.Views.ShareModal
        model: @model
        postsView: @postsView
      $('#js-likes-modal-container').html(modal.render().el)

    showLikes: (e)->
      e.preventDefault()
      view = @
      # fetch all likes
      @model.likesCollection.fetch
        success: (collection)->
          modal = new AlumNet.Shared.Views.LikesModal
            model: view.model
            likes: collection
          $('#js-likes-modal-container').html(modal.render().el)

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
              $('.ui-autocomplete-input').css('height','34px');
              $('.ui-autocomplete-input').css('background-color','white');

    extractMentions: (mentions)->
      array = []
      _.each mentions, (mention)->
        array.push mention.uid
      array.join(",")

    clickedEdit: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.options.dropdown("toggle")
      @ui.bodyPost.editable('toggle')

    clickedDelete: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.options.dropdown("toggle")
      resp = confirm "Are you sure?"
      if resp
        @model.destroy()

    clickedLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      post = @model
      like = AlumNet.request("like:post:new", post.id)
      like.save {},
        success: ->
          post.sumLike()
          view.sumLike()
          $('[data-toggle="tooltip"]').tooltip({html:true});

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      post = @model
      unlike = AlumNet.request("unlike:post:new", post.id)
      unlike.save {},
        success: ->
          post.remLike()
          view.remLike()
          $('[data-toggle="tooltip"]').tooltip({html:true});

    sumLike: ->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-like').addClass('js-unlike').
        html('<span class="glyphicon glyphicon-thumbs-down"></span> Unlike')
      @updateLikeText()

    remLike: ->
      val = parseInt(@ui.likeCounter.html()) - 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-unlike').addClass('js-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')
      @updateLikeText()

    updateLikeText: (remove)->
      html = @ui.likesLinks.html().trim()
      if (/(You,)/i).test(html)
        newText = html.replace('You,', '')
      else
        # TODO: revisar donde se agregar el espacio entre You y like :armando
        if html == "You like this." || html == "You  like this."
          newText = ""
        else if html == ""
          newText = "You like this."
        else
          newText = "You, #{html}"
      @ui.likesLinks.html(newText)

    clickedGotoComment: (e)->
      e.stopPropagation()
      e.preventDefault()
      @ui.commentInput.focus()

    loadMore: (e)->
      $(e.currentTarget).hide()
      e.stopPropagation()
      e.preventDefault()
      self = @
      @model.comments.fetch
        success: (collection)->
          self.collection.add(collection.models)

    hidePopover: ->
      @$("#userPopover"+@model.id).popover('hide');

  #
  # POSTS COLLECTION
  # the model of this view is the postable entity :user, :current_user, :group, :event
  #

  class Views.PostsView extends Marionette.CompositeView
    template: '_shared/posts/templates/posts_container'
    childView: Views.PostView
    childViewContainer: '.posts-container'
    childViewOptions: ->
      postsView: @

    initialize: ->
      @picture_ids = []

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMorePost')
      $(window).scroll(@loadMorePost)

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    loadMorePost: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'post:reload'

    templateHelpers: ->
      userCanPost: true
      current_user_avatar: AlumNet.current_user.get('avatar').large

    ui: ->
      'bodyInput': '#body'
      'timeline': '#timeline'
      'fileList': '#js-filelist'
      'uploadLink': '#upload-picture'
      'postContainer': '#timeline'
      'tagsInput': '#js-user-tags-list'
      'tagging': '.tagging'
      'videoContainer': '#video_container'
      'preview_url': '#url'
      'preview_title': '#url_title'
      'preview_description': '#url_description'
      'preview_image': '#url_image'
      'loading': '.throbber-loader'

    events: ->
      'click a#js-post-submit': 'submitClicked'
      'click a#js-add-tags': 'showTagging'
      'keyup @ui.bodyInput': 'checkInput'

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

    ifUrl: (url)->
      url = $.trim(url)
      p = /(http|ftp|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/
      url.match(p)

    checkInput: (e)->
      validation = @ytVidId( @ui.bodyInput.val().split(" ").pop() )
      if validation
        @ui.videoContainer.html('<img src="https://i.ytimg.com/vi/'+validation+'/hqdefault.jpg" />')
      else
        ui = @ui
        if ( @ifUrl(@ui.bodyInput.val().split(" ").pop()) )
          url = @ui.bodyInput.val().split(" ").pop()
          Backbone.ajax
            url: AlumNet.api_endpoint + '/metatags'
            data: {url: url}
            success: (data)->
              ui.videoContainer.html('<div class="row"><div class="col-sm-4 col-md-6 col-lg-5 text-center" style="padding: 13px;"><img src="'+data.image+'" class="imageEvents"></div><div class="col-sm-8 col-md-6 col-lg-7"><div class="row"><div class="col-md-12"><h4>'+data.title+'</h4></div></div><div class="row"><div class="col-md-12">'+data.description+'</div></div></div></div>')
              ui.preview_image.val(data.image)
              ui.preview_description.val(data.description)
              ui.preview_title.val(data.title)
              ui.preview_url.val(url)

    submitClicked: (e)->
      throw 'Implement this function'