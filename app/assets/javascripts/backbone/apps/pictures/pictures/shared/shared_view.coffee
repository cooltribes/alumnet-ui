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


  API =
    getPictureModal: (picture)->
      new PictureShared.PictureModal
        model: picture
        # collection: picture.comments


  AlumNet.reqres.setHandler 'picture:modal', (picture) ->
    API.getPictureModal(picture)
