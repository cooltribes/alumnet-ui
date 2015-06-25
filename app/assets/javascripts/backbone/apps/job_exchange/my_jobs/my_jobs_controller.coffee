@AlumNet.module 'JobExchangeApp.MyJobs', (MyJobs, @AlumNet, Backbone, Marionette, $, _) ->
  class MyJobs.Controller
    myJobs: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/my'
      myJobsView = new MyJobs.List
        collection: tasks

      AlumNet.mainRegion.show(myJobsView)
      AlumNet.execute('render:job_exchange:submenu', undefined, 0)