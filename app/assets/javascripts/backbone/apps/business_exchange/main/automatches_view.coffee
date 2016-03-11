@AlumNet.module 'BusinessExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    template: 'business_exchange/main/templates/automatches_task'

  class AutoMatches.EmptyView extends Marionette.ItemView
   	template: 'business_exchange/main/templates/empty_automatches'

  class AutoMatches.List extends Marionette.CompositeView
    template: 'business_exchange/main/templates/automatches_container'
    childView: AutoMatches.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'
    emptyView: AutoMatches.EmptyView