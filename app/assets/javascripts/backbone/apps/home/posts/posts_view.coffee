@AlumNet.module 'HomeApp.Posts', (Posts, @AlumNet, Backbone, Marionette, $, _) ->
  # LIKE MODAL
  class Posts.LikesModal extends AlumNet.Shared.Views.LikesModal

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
      comment: @model.commentWithLinks()

    onRender: ->
      view = this

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
    className: 'post item col-xs-12 col-sm-6 col-md-6'

    childViewOptions: ->
      current_user: @current_user

    initialize: (options)->
      @comments = options.model.comments
      @current_user = options.current_user
      @model.url = AlumNet.api_endpoint + @model.get('resource_path')
      self = @
      self.collection = new AlumNet.Entities.CommentsCollection
      self.collection.comparator = 'created_at'
      @model.comments.fetch
        success: (collection)->
          start =
          #if collection.length > 0
          #  $(".groupPost__commentsContainer").addClass('groupPost__comment--scroll')
          if collection.length > 3
            self.collection.add(collection.slice((collection.length-3),collection.length))
            $(self.ui.moreComment).show()

          else
            self.collection.add(collection.models)
            $(self.ui.moreComment).hide()
          #console.log self
      #subdelegating the events on commentsView to postView
      @on 'childview:comment:like', (commentView) ->
        @trigger 'comment:like', commentView
      @on 'childview:comment:unlike', (commentView) ->
        @trigger 'comment:unlike', commentView
      @on 'childview:comment:edit', (commentView, newValue) ->
        @trigger 'comment:edit', commentView, newValue

    templateHelpers: ->
      model = @model
      permissions = @model.get('permissions')

      current_user_avatar: @current_user.get('avatar').medium
      infoLink: @model.infoLink()
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete
      showMore: @mostrar
      tagsLinks: @model.tagsLinks()
      likesLinks: @model.firstLikeLinks()
      restLikeLink: @model.restLikeLink()

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

      # Autosize
      self = @
      @ui.commentInput.autoResize(onResize: -> setTimeout(self.reloadMasonry, 400))

      # Mentions in comments
      @ui.commentInput.mentionsInput
        source: AlumNet.api_endpoint + '/me/friendships/suggestions'
    
    reloadMasonry: ->
      $('#timeline').masonry() 

    onRender: ->
      $('[data-toggle="tooltip"]').tooltip({html:true});
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
          validation = @ytVidId(newValue.split(" ").pop())
          if validation
            temp_string = newValue
            $(this).html(temp_string.replace(newValue.split(" ").pop(),'<div class="video-container"><iframe width="420" height="315" src="http://www.youtube.com/embed/'+validation+'"></iframe></div>'))

      validation = @ytVidId(@ui.bodyPost.html().split(" ").pop())
      if validation
        temp_string = @ui.bodyPost.html()
        @ui.bodyPost.html(temp_string.replace(@ui.bodyPost.html().split(" ").pop(),'<div class="video-container"><iframe width="420" height="315" src="http://www.youtube.com/embed/'+validation+'"></iframe></div>'))
      else
        @ui.bodyPost.linkify()

    ui:
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

    events:
      'keypress .comment': 'commentSend'
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
      'click .js-goto-comment': 'clickedGotoComment'
      'click @ui.editLink': 'clickedEdit'
      'click @ui.deleteLink': 'clickedDelete'
      'click .picture-post': 'clickedPicture'
      'click @ui.moreComment': 'loadMore'
      'click .js-show-likes': 'showLikes'

    showLikes: (e)->
      e.preventDefault()
      view = @
      # fetch all likes
      @model.likesCollection.fetch
        success: (collection)->
          modal = new Posts.LikesModal
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
      @trigger 'post:like'

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'post:unlike'

    sumLike: ->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-like').addClass('js-unlike').html('unlike')
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

  class Posts.PostsView extends Marionette.CompositeView
    ##model is current user
    template: 'home/posts/templates/posts_container'
    childView: Posts.PostView
    childViewContainer: '.posts-container'

    initialize: ->
      document.title = " AlumNet - Home"
      @picture_ids = []
      
    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreBooks')      
      $(window).scroll(@loadMoreBooks)
      

    remove: ->
      @collection.page = 1
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @collection.page = 1
      @ui.loading.hide()
      $(window).unbind('scroll')      

    loadMoreBooks: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'post:reload'

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
      'tagsInput': '#js-user-tags-list'
      'tagging': '.tagging'
      'videoContainer': '#video_container'
      'preview_url': '#url'
      'preview_title': '#url_title'
      'preview_description': '#url_description'
      'preview_image': '#url_image'
      'loading': '.throbber-loader'

    events:
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
              ui.videoContainer.html('<div class="row"><div class="col-sm-4 col-md-5 col-lg-4 text-center" style="padding: 13px;"><img src="'+data.image+'" height="100px" width="165px"/></div><div class="col-sm-8 col-md-7 col-lg-8"><div class="row"><div class="col-md-12"><h4>'+data.title+'</h4></div></div><div class="row"><div class="col-md-12">'+data.description+'</div></div></div></div>')
              ui.preview_image.val(data.image)
              ui.preview_description.val(data.description)
              ui.preview_title.val(data.title)
              ui.preview_url.val(url)


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