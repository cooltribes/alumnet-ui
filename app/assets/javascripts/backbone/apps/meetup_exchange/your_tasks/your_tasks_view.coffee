@AlumNet.module 'MeetupExchangeApp.YourTasks', (YourTasks, @AlumNet, Backbone, Marionette, $, _) ->
  class YourTasks.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'container'
    template: 'meetup_exchange/_shared/templates/task'

  class YourTasks.List extends Marionette.CompositeView
    template: 'meetup_exchange/your_tasks/templates/your_tasks_container'
    childView: YourTasks.Task
    childViewContainer: '.tasks-container'
    className: 'container'
