@AlumNet.module 'JobExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/discover_task'

  class AutoMatches.List extends Marionette.CompositeView
    template: 'job_exchange/automatches/templates/automatches_container'
    childView: AutoMatches.Task
    childViewContainer: '.tasks-container'
