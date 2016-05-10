@AlumNet.module 'BusinessExchangeApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->
  class Home.Tasks extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Task

    initialize: (options)->
      @query = options.query

      @collection.fetch
        reset: true
        remove: true
        data: @query

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMore')
      $(window).scroll(@loadMore)

    remove: ->
      $(window).unbind('scroll');
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      $(window).unbind('scroll')

    loadMore: (e)->
      if @collection.nextPage == null
        @endPagination()
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @reloadItems()

    reloadItems: ->
      @query.page = @collection.nextPage
      @collection.fetch
        remove: false
        reset: false
        data: @query


  class Home.Profiles extends Marionette.CollectionView
    childView: AlumNet.BusinessExchangeApp.Shared.Profile

