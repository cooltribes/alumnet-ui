@AlumNet.module 'JobExchangeApp.MyJobs', (MyJobs, @AlumNet, Backbone, Marionette, $, _) ->
  class MyJobs.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/task'
    className: 'col-md-4'

  class MyJobs.List extends Marionette.CompositeView
    template: 'job_exchange/my_jobs/templates/my_jobs_container'
    childView: MyJobs.Task
    childViewContainer: '.tasks-container'
    
    initialize: ->
      $(window).unbind('scroll');
      _.bindAll(this, 'loadMoreJobs')
      $(window).scroll(@loadMoreJobs)

    loadMoreJobs: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'job:reload'

    getEmptyView: ->
      AlumNet.Utilities.GeneralEmptyView
    emptyViewOptions: 
      message: "You don't have any active Post."
    className: 'container-fluid'
