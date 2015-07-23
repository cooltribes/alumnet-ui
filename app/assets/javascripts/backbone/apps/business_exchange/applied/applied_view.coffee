@AlumNet.module 'BusinessExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    template: 'business_exchange/_shared/templates/discover_task'

  class Applied.List extends Marionette.CompositeView
    template: 'business_exchange/applied/templates/applied_container'
    childView: Applied.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

