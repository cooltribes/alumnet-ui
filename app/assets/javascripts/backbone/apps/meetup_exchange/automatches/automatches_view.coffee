@AlumNet.module 'MeetupExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    template: 'meetup_exchange/_shared/templates/discover_task'

  class AutoMatches.List extends Marionette.CompositeView
    template: 'meetup_exchange/automatches/templates/automatches_container'
    childView: AutoMatches.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    
