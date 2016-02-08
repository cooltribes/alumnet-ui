@AlumNet.module 'BusinessExchangeApp.YourTasks', (YourTasks, @AlumNet, Backbone, Marionette, $, _) ->
  class YourTasks.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    className: 'col-md-6'
    template: 'business_exchange/_shared/templates/task'

  class YourTasks.EmptyView extends Marionette.ItemView
    template: 'business_exchange/_shared/templates/empty'

  class YourTasks.List extends Marionette.CompositeView
    template: 'business_exchange/your_tasks/templates/your_tasks_container'
    childView: YourTasks.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    emptyView: YourTasks.EmptyView