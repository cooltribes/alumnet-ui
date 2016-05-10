@AlumNet.module 'JobExchangeApp.MyJobs', (MyJobs, @AlumNet, Backbone, Marionette, $, _) ->
  class MyJobs.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/task'
    className: 'col-md-6'

  class MyJobs.EmptyView extends Marionette.ItemView
    template: 'job_exchange/main/templates/empty_my_jobs_exchange'

  class MyJobs.List extends Marionette.CompositeView
    template: 'job_exchange/main/templates/my_jobs_container'
    childView: MyJobs.Task
    childViewContainer: '.tasks-container'
    emptyView: MyJobs.EmptyView

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