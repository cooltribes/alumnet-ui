@AlumNet.module 'BusinessExchangeApp.Show', (Show, @AlumNet, Backbone, Marionette, $, _) ->
  class Show.Task extends AlumNet.BusinessExchangeApp.Shared.Task
    className: 'container'
    template: 'business_exchange/_shared/templates/detail_task'

