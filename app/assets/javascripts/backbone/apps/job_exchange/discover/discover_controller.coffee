@AlumNet.module 'JobExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch()
      discoverView = new Discover.List
        collection: tasks

      AlumNet.mainRegion.show(discoverView)
      AlumNet.execute('render:job_exchange:submenu', undefined, 2)
