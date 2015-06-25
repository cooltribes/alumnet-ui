@AlumNet.module 'JobExchangeApp.Show', (Show, @AlumNet, Backbone, Marionette, $, _) ->
  class Show.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/detail_task'

