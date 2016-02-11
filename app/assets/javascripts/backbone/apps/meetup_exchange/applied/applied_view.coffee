@AlumNet.module 'MeetupExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'col-md-6'
    template: 'meetup_exchange/_shared/templates/discover_task'

  class Applied.List extends Marionette.CompositeView
    template: 'meetup_exchange/applied/templates/applied_container'
    childView: Applied.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

