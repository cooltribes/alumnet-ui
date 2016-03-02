@AlumNet.module 'MeetupExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    template: 'meetup_exchange/automatches/templates/automatches_meetup'
    className: 'col-md-4'

  class AutoMatches.EmptyView extends Marionette.ItemView
    template: 'meetup_exchange/automatches/templates/empty_meetups'

  class AutoMatches.List extends Marionette.CompositeView
    template: 'meetup_exchange/automatches/templates/automatches_container'
    childView: AutoMatches.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    emptyView: AutoMatches.EmptyView


    
