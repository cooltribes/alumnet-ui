@AlumNet.module 'JobExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/discover_task'

  class Discover.List extends Marionette.CompositeView
    template: 'job_exchange/discover/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'

