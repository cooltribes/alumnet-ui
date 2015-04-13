@AlumNet.module 'PicturesApp.PictureShared', (PictureShared, @AlumNet, Backbone, Marionette, $, _) ->
  class PictureShared.PictureModal extends Backbone.Modal
    template: 'pictures/pictures/shared/templates/_detailModal'
    className: "picture-modal"
    cancelEl: '.js-close'
    # submitEl: '#js-save'
    keyControl: false
    # prefix: "picture"

    events:
      "click .js-next-picture": "nextPicture"
      "click .js-prev-picture": "prevPicture"

    initialize: (options)->
      @view = options.view

      # Backbone.Validation.bind this,
      #   valid: (view, attr, selector) ->
      #     $el = view.$("[name=#{attr}]")
      #     $group = $el.closest('.form-group')
      #     $group.removeClass('has-error')
      #     $group.find('.help-block').html('').addClass('hidden')
      #   invalid: (view, attr, error, selector) ->
      #     $el = view.$("[name=#{attr}]")
      #     $group = $el.closest('.form-group')
      #     $group.addClass('has-error')
      #     $group.find('.help-block').html(error).removeClass('hidden')

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

      # creator: model.collection.album.get("creator")

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

  API =
    getPictureModal: (picture)->
      new PictureShared.PictureModal
        model: picture


  AlumNet.reqres.setHandler 'picture:modal', (picture) ->
    API.getPictureModal(picture)
