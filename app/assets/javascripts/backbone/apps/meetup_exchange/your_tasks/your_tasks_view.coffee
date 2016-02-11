@AlumNet.module 'MeetupExchangeApp.YourTasks', (YourTasks, @AlumNet, Backbone, Marionette, $, _) ->
  class YourTasks.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'col-md-6'
    template: 'meetup_exchange/_shared/templates/task'

  class YourTasks.EmptyView extends Marionette.ItemView
    template: 'meetup_exchange/your_tasks/templates/empty'

  class YourTasks.List extends Marionette.CompositeView
    emptyView: YourTasks.EmptyView
    template: 'meetup_exchange/your_tasks/templates/your_tasks_container'
    childView: YourTasks.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    onRender: ->
      $("#iconModalMeetup").addClass("hide")
