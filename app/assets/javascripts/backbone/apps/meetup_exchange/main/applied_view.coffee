@AlumNet.module 'MeetupExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'col-md-6'
    template: 'meetup_exchange/_shared/templates/discover_task'

  class Applied.EmptyView extends Marionette.ItemView
    template: 'meetup_exchange/main/templates/empty_applied'

  class Applied.List extends Marionette.CompositeView
    emptyView: Applied.EmptyView
    template: 'meetup_exchange/main/templates/applied_container'
    childView: Applied.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    onRender: ->
      $("#iconModalMeetup").addClass("hide")
      

