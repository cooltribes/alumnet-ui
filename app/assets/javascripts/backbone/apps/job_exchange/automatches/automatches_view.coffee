@AlumNet.module 'JobExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/discover_task'
    className: 'col-md-4'

  class AutoMatches.EmptyView extends Marionette.ItemView
    template: 'job_exchange/automatches/templates/empty_job_exchange'

  class AutoMatches.List extends Marionette.CompositeView
    template: 'job_exchange/automatches/templates/automatches_container'
    childView: AutoMatches.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    emptyView: AutoMatches.EmptyView
    
    initialize: ->
      $(window).unbind('scroll');
      _.bindAll(this, 'loadMoreJobs')
      $(window).scroll(@loadMoreJobs)

    loadMoreJobs: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'job:reload'