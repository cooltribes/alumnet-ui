@AlumNet.module 'BusinessExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    template: 'business_exchange/_shared/templates/discover_task'

  class AutoMatches.EmptyView extends Marionette.ItemView
   	template: 'business_exchange/automatches/templates/empty_automatches'

  class AutoMatches.List extends Marionette.CompositeView
    template: 'business_exchange/automatches/templates/automatches_container'
    childView: AutoMatches.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    emptyView: AutoMatches.EmptyView