@AlumNet.module 'JobExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/discover_task'
    className: 'col-md-4'

  class Applied.List extends Marionette.CompositeView
    template: 'job_exchange/applied/templates/applied_container'
    childView: Applied.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    initialize: ->
      $(window).unbind('scroll');
      _.bindAll(this, 'loadMoreJobs')
      $(window).scroll(@loadMoreJobs)

    loadMoreJobs: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'job:reload'    	
