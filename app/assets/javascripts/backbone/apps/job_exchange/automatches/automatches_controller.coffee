@AlumNet.module 'JobExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Controller
    automatches: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/automatches'
      automatchesView = new AutoMatches.List
        collection: tasks

      AlumNet.mainRegion.show(automatchesView)
      AlumNet.execute('render:job_exchange:submenu', undefined, 1)
