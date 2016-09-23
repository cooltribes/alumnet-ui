@AlumNet.module 'Shared.Views', (Views, @AlumNet, Backbone, Marionette, $, _) ->
  class Views.ContentView extends Marionette.ItemView
    template: '_shared/posts/templates/content'

    initialize: (options)->
      @previewMode = if options.previewMode == undefined then false else options.previewMode
      @postsView = options.postsView
      @postPictures = @model.get('pictures')

    templateHelpers: ->
      view = @
      model = @model

      infoLink: @model.infoLink()
      postUrl: @model.postUrl()
      previewMode: @previewMode

      pictures_is_odd: (pictures)->
        pictures.length % 2 != 0

      picturesToShow: ->
        if view.postPictures.length > 5
          _.first(view.postPictures, 5)
        else
          view.postPictures

    ui: ->
      'item': '.item'
      'bodyPost': '#js-body-post'
      'picturesContainer': '.pictures-container'
      'modalContainer': '.modal-container'

    events: ->
      'click .picture-post': 'clickedPicture'
      'click .js-share-post': 'showShare'

    onRender: ->
      if @postPictures && @postPictures.length > 1
        container = @ui.picturesContainer
        # container.imagesLoaded ->
        #   container.masonry
        #     columnWidth: '.item'
        #     gutter: 1

      validation = @ytVidId(@ui.bodyPost.html().split(" ").pop())
      if validation
        temp_string = @ui.bodyPost.html()
        @ui.bodyPost.html(temp_string.replace(@ui.bodyPost.html().split(" ").pop(),'<div class="video-container"><iframe width="420" height="315" src="http://www.youtube.com/embed/'+validation+'"></iframe></div>'))
      else
        @ui.bodyPost.linkify()

    ytVidId: (url)->
      url = $.trim(url)
      p = /^(?:https?:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))((\w|-){11})(?:\S+)?$/
      if (url.match(p)) then RegExp.$1 else false

    clickedPicture: (e)->
      e.preventDefault()
      return if @previewMode
      element = $(e.currentTarget)
      id = element.data('id')
      picture = @model.picture_collection.get(id)
      modal = AlumNet.request "picture:modal", picture
      @ui.modalContainer.html(modal.render().el)

    # showShare: (e)->
    #   e.preventDefault()
    #   return if @previewMode
    #   modal = new AlumNet.Shared.Views.ShareModal
    #     model: @model
    #     postsView: @postsView
    #   $('#js-likes-modal-container').html(modal.render().el)