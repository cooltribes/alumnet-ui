@AlumNet.module 'JobExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Controller
    applied: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/applied'
      appliedJobsView = new Applied.List
        collection: tasks

      AlumNet.mainRegion.show(appliedJobsView)
      AlumNet.execute('render:job_exchange:submenu', undefined, 3)