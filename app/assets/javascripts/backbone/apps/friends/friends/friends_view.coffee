@AlumNet.module 'FriendsApp.Friends', (Friends, @AlumNet, Backbone, Marionette, $, _) ->
  class Friends.EmptyView extends Marionette.ItemView
    template: 'friends/friends/templates/empty'

  class Friends.FriendsView extends Marionette.CompositeView
    template: 'friends/friends/templates/friends'
    childView: AlumNet.FriendsApp.Find.UserView
    childViewContainer: '.friends-container'
    emptyView: Friends.EmptyView

    initialize: (options)->
      @parentView = options.parentView
      @query = options.query

    ui:
      'loading': '.throbber-loader'

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreUsers')
      $(window).scroll(@loadMoreUsers)

      if @query
        @showLoading()
        @collection.fetch
          reset: true
          remove: true
          data: @query

      @listenTo @collection, 'request', @showLoading
      @listenTo @collection, 'sync', @hideLoading

    showLoading: ->
      @ui.loading.show()

    hideLoading: ->
      @ui.loading.hide()

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    loadMoreUsers: (e)->
      if @collection.nextPage == null
        @endPagination()
      else
        if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
          @reloadItems()

    reloadItems: ->
      if @query
        @query.page = @collection.nextPage
        @collection.fetch
          data: @query
          remove: false
          reset: false

    onChildviewCatchUp: ->
      view = @
      @collection.fetch
        success: (model)->
          view.render()