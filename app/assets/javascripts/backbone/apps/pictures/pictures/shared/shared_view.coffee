@AlumNet.module 'PicturesApp.PictureShared', (PictureShared, @AlumNet, Backbone, Marionette, $, _) ->
  class PictureShared.PictureModal extends Backbone.Modal
    template: 'pictures/pictures/shared/templates/_detailModal'
    className: "picture-modal"
    cancelEl: '.js-close'
    # submitEl: '#js-save'
    keyControl: false
    # prefix: "picture"

    ui:
      'likeLink': '.js-vote'
      'likeCounter': '.js-likes-counter'

    events:
      'click .js-like': 'clickedLike'
      'click .js-unlike': 'clickedUnLike'
      "click .js-next-picture": "nextPicture"
      "click .js-prev-picture": "prevPicture"
      'click .js-tag-friend': "Tagging"
      'mouseover .js-tags a': "showTag"
      'mouseout .js-tags a': "hideTag"

    regions:
      'comments': '#comments-region'

    initialize: (options)->
      @view = options.view
      @model.comments.fetch
        wait: true

    onShow: ->
      modal = @
      Backbone.ajax
        url: AlumNet.api_endpoint + "/pictures/#{@model.id}/user_tags"
        success: (data)->
          modal.tagger = $('.picture').photo_tagging
            model: modal.model
            tags: data
            addCallback: modal.addLinkTag
            submitCallback: modal.submitTag
            inputCallback: modal.addSelect2toInput

      @commentsView = new PictureShared.Comments
        collection: @model.comments
        model: @model

      @comments.show @commentsView

    templateHelpers: ->

      model = @model
      img = $("<img>").attr("src", @model.attributes.picture.original).load()
      proportion = parseFloat(parseInt(img[0].width,10) / parseInt(img[0].height,10))*5
      h= parseInt(img[0].width,10) > parseInt(img[0].height,10)  && proportion > 8
      delete img[0]
      horizontal: h
      top : proportion
      showMorePics: @model.collection.length > 1

      getLocation: ->
        model.getLocation()

      current_user_avatar: AlumNet.current_user.get('avatar').medium

    nextPicture: (e)->
      e.stopPropagation()
      e.preventDefault()
      @model = @model.next()
      @render()

    prevPicture: (e)->
      e.stopPropagation()
      e.preventDefault()
      @model = @model.prev()
      @render()

    clickedLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      picture = @model
      thisView = @
      like = AlumNet.request("like:picture:new", picture.id)
      like.save {},
        success: ->
          # console.log thisView
          # picture.sumLike()
          thisView.sumLike()
          # console.log thisView

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      picture = @model
      thisView = @
      unlike = AlumNet.request("unlike:picture:new", picture.id)
      unlike.save {},
        success: ->
          # picture.remLike()
          thisView.remLike()

    sumLike:()->
      # @model.sumLike()
      likeLink = @$(".js-vote")
      likeCounter = @$(".js-likes-counter")
      val = parseInt(likeCounter.html()) + 1
      likeCounter.html(val)
      likeLink.removeClass('js-like').addClass('js-unlike').
      html('<span class="glyphicon glyphicon-thumbs-down"></span> Unlike')

    remLike:()->
      # @model.remLike()
      likeLink = @$(".js-vote")
      likeCounter = @$(".js-likes-counter")
      val = parseInt(likeCounter.html()) - 1
      likeCounter.html(val)
      likeLink.removeClass('js-unlike').addClass('js-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')

    #TAGGING
    Tagging: (e)->
      e.preventDefault()
      link = $(e.currentTarget)
      console.log link
      if link.html() == "STOP TAGGING"
        link.html("TAG A FRIEND")
        @tagger.inactiveTagger()
      else
        link.html("STOP TAGGING")
        @tagger.activeTagger()

    showTag: (e)->
      link = $(e.currentTarget)
      @tagger.showTag(link.data('tag'))

    hideTag: (e)->
      link = $(e.currentTarget)
      @tagger.hideTag(link.data('tag'))

    addLinkTag: (id, user_id, user_name, posX, posY)->
      $('.js-tags').append("<a href='#users/#{user_id}/posts' data-tag=#{id}>#{user_name}</a>")

    submitTag: (plugin, user_id, user_name, posX, posY)->
      Backbone.ajax
        url: AlumNet.api_endpoint + "/pictures/#{@model.id}/user_tags"
        method: 'POST'
        data: { user_id: user_id, position: { posX: posX, posY: posY } }
        success: (data)->
          plugin.addTag(data.id, data.user_id, data.user_name, data.posX, data.posY)

    addSelect2toInput: (input_id)->
      $(input_id).select2
        placeholder: "Tag a Friend"
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

  class PictureShared.Comment extends Marionette.ItemView
    template: 'pictures/pictures/shared/templates/_comment'

    initialize: (options)->
      @picture = options.picture

    templateHelpers: ->
      permissions = @model.get('permissions')
      canEdit: permissions.canEdit
      canDelete: permissions.canDelete
      comment: @model.commentWithLinks()

    ui:
      'likeLink': '.js-comment-vote'
      'likeCounter': '.js-comment-likes-counter'
      'editLink': '#js-edit-comment'
      'deleteLink': '#js-delete-comment'
      'commentText': '#js-comment-text'

    events:
      'click .js-comment-like': 'clickedLike'
      'click .js-comment-unlike': 'clickedUnLike'
      'click @ui.editLink': 'clickedEdit'
      'click @ui.deleteLink': 'clickedDelete'

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
      @model.destroy()

    clickedLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      like = AlumNet.request("like:comment:new", @picture.id, @model.id, 'pictures')
      like.save {},
        success: (model)->
          view.model.sumLike()
          view.sumLike()

    clickedUnLike: (e)->
      e.stopPropagation()
      e.preventDefault()
      view = @
      unlike = AlumNet.request("unlike:comment:new", @picture.id, @model.id, 'pictures')
      unlike.save {},
        success: (model)->
          view.model.remLike()
          view.remLike()

    sumLike:()->
      val = parseInt(@ui.likeCounter.html()) + 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-comment-like').addClass('js-comment-unlike').html('unlike')

    remLike:()->
      val = parseInt(@ui.likeCounter.html()) - 1
      @ui.likeCounter.html(val)
      @ui.likeLink.removeClass('js-comment-unlike').addClass('js-comment-like').
        html('<span class="icon-entypo-thumbs-up"></span> Like')

  class PictureShared.Comments extends Marionette.CompositeView
    template: 'pictures/pictures/shared/templates/comments'
    childView: PictureShared.Comment
    childViewContainer: '.comments-container'
    childViewOptions: ->
      picture: @model

    initialize: (options)->
      @collection.fetch()

    templateHelpers: ->
      current_user_avatar: AlumNet.current_user.get('avatar').medium

    ui:
      'commentInput': '.comment'
      'commentButton': '#commentB'

    events:
      'keypress .comment': 'commentSend'
      'click @ui.commentButton': 'commentSendButtons'

    onShow: ->
      # Autosize
      @ui.commentInput.autoResize()

      # Mentions in comments
      @ui.commentInput.mentionsInput
        source: AlumNet.api_endpoint + '/me/friendships/suggestions'

    commentSend: (e)->
      e.stopPropagation()
      if e.keyCode == 13
        e.preventDefault()
        data = Backbone.Syphon.serialize(this)
        if data.body != ''
          console.log data, @model
          view = @
          comment = AlumNet.request('comment:picture:new', @model.id)
          data.comment = @ui.commentInput.mentionsInput('getRawValue')
          data.markup_comment = @ui.commentInput.mentionsInput('getValue')
          data.user_tags_list = @extractMentions @ui.commentInput.mentionsInput('getMentions')
          console.log data, comment
          comment.save data,
            success: (model, response, options)->
              view.ui.commentInput.val('')
              view.collection.add(model, {at: view.collection.length})

    commentSendButtons: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != ''
        console.log data, @model
        view = @
        comment = AlumNet.request('comment:picture:new', @model.id)
        data.comment = @ui.commentInput.mentionsInput('getRawValue')
        data.markup_comment = @ui.commentInput.mentionsInput('getValue')
        data.user_tags_list = @extractMentions @ui.commentInput.mentionsInput('getMentions')
        console.log data, comment
        comment.save data,
          success: (model, response, options)->
            view.ui.commentInput.val('')
            view.collection.add(model, {at: view.collection.length})

    extractMentions: (mentions)->
      array = []
      _.each mentions, (mention)->
        array.push mention.uid
      array.join(",")


  API =
    getPictureModal: (picture)->
      new PictureShared.PictureModal
        model: picture

  AlumNet.reqres.setHandler 'picture:modal', (picture) ->
    API.getPictureModal(picture)
