@AlumNet.module 'MeetupExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    template: 'meetup_exchange/main/templates/_meetup_automatches'

  class AutoMatches.EmptyView extends Marionette.ItemView
    template: 'meetup_exchange/main/templates/empty_automatches'

  class AutoMatches.List extends Marionette.CompositeView
    template: 'meetup_exchange/main/templates/automatches_container'
    childView: AutoMatches.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    emptyView: AutoMatches.EmptyView


    
