@AlumNet.module 'BusinessExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    className: 'container'
    template: 'business_exchange/_shared/templates/discover_task'

  class Discover.List extends Marionette.CompositeView
    template: 'business_exchange/discover/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'
    className: 'container'

