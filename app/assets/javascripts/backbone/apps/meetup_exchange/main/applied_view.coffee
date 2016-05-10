@AlumNet.module 'MeetupExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'col-md-6'
    template: 'meetup_exchange/_shared/templates/discover_task'

  class Applied.EmptyView extends Marionette.ItemView
    template: 'meetup_exchange/main/templates/empty_applied'

  class Applied.List extends Marionette.CompositeView
    emptyView: Applied.EmptyView
    template: 'meetup_exchange/main/templates/applied_container'
    childView: Applied.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

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
      $("#iconModalMeetup").removeClass("hide")

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