@AlumNet.module 'JobExchangeApp.MyJobs', (MyJobs, @AlumNet, Backbone, Marionette, $, _) ->
  class MyJobs.Controller
    myJobs: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.page = 1
      tasks.url = AlumNet.api_endpoint + '/job_exchanges/my?page='+tasks.page+'&per_page='+tasks.rows      
      tasks.fetch
        reset: true

      myJobsView = new MyJobs.List
        collection: tasks

      myJobsView.on "job:reload", ->
        ++myJobsView.collection.page
        newCollection = new AlumNet.Entities.JobExchangeCollection
        newCollection.url = AlumNet.api_endpoint + '/job_exchanges/my?page='+myJobsView.collection.page+'&per_page='+myJobsView.collection.rows
        newCollection.fetch
          success: (collection)->
            console.log collection
            myJobsView.collection.add(collection.models)

      myJobsView.on "add:child", (viewInstance)->
        container = $('#tasks-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'        
          container.append( $(viewInstance.el) ).masonry 'reloadItems'

      # attach events
      AlumNet.mainRegion.show(myJobsView)
      AlumNet.execute('render:job_exchange:submenu', undefined, 0)