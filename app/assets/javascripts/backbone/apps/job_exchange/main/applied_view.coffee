@AlumNet.module 'JobExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/discover_task'
    className: 'col-md-6'

  class Applied.EmptyView extends Marionette.ItemView
    template: 'job_exchange/main/templates/empty_applied'

  class Applied.List extends Marionette.CompositeView
    emptyView: Applied.EmptyView
    template: 'job_exchange/main/templates/applied_container'
    childView: Applied.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    ui:
      'loading': '.throbber-loader'
      
    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreJobs')      
      $(window).scroll(@loadMoreJobs)
      $("#iconModalJob").addClass("hide")
      
    remove: ->
      @collection.page = 1
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @collection.page = 1
      @ui.loading.hide()
      $(window).unbind('scroll') 

    loadMoreJobs: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'job:reload'
  	
