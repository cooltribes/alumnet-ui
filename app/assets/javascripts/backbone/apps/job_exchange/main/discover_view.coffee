@AlumNet.module 'JobExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.Task extends AlumNet.Shared.Views.JobExchange.Task
    template: 'job_exchange/_shared/templates/discover_task'
    className: 'col-lg-6 col-md-6 col-sm-6 col-xs-12'

  class Discover.EmptyView extends Marionette.ItemView
    template: 'job_exchange/main/templates/empty_discover'

  class Discover.List extends Marionette.CompositeView
    emptyView: Discover.EmptyView
    template: 'job_exchange/main/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    ui:
      'loading': '.throbber-loader'

    initialize: (options)->
      @query = options.query

      @collection.fetch
        reset: true
        remove: true
        data: @query

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreJobs')
      $(window).scroll(@loadMoreJobs)
      $("#iconModalJob").removeClass("hide")

    remove: ->
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    loadMoreJobs: (e)->
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

    fetch_and_format_seniorities: ->
      seniorities = new AlumNet.Utilities.Seniorities
      seniorities.fetch()
      _.map seniorities.results, (senority)->
        { value: senority.id,  text: senority.name }