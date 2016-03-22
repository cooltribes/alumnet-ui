@AlumNet.module 'JobExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/main/templates/_job_exchange_automatches'

  class AutoMatches.EmptyView extends Marionette.ItemView
    template: 'job_exchange/main/templates/empty_automatches'

  class AutoMatches.List extends Marionette.CompositeView
    template: 'job_exchange/main/templates/automatches_container'
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