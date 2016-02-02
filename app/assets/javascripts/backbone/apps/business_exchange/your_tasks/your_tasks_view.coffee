@AlumNet.module 'BusinessExchangeApp.YourTasks', (YourTasks, @AlumNet, Backbone, Marionette, $, _) ->
  class YourTasks.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    className: 'col-md-6'
    template: 'business_exchange/_shared/templates/task'

  class YourTasks.List extends Marionette.CompositeView
    template: 'business_exchange/your_tasks/templates/your_tasks_container'
    childView: YourTasks.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    getEmptyView: ->
      AlumNet.Utilities.GeneralEmptyView
    emptyViewOptions: 
      message: "You don't have any active Task."
