@AlumNet.module 'JobExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Controller
    applied: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.page = 1
      tasks.url = AlumNet.api_endpoint + '/job_exchanges/applied?page='+tasks.page+'&per_page='+tasks.rows       
      tasks.fetch
        reset: true

      appliedJobsView = new Applied.List
        collection: tasks

      appliedJobsView.on "job:reload", ->
        ++appliedJobsView.collection.page
        newCollection = new AlumNet.Entities.JobExchangeCollection
        newCollection.url = AlumNet.api_endpoint + '/job_exchanges/applied?page='+appliedJobsView.collection.page+'&per_page='+appliedJobsView.collection.rows
        newCollection.fetch
          success: (collection)->
            console.log collection
            appliedJobsView.collection.add(collection.models)

      appliedJobsView.on "add:child", (viewInstance)->
        container = $('#tasks-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'        
          container.append( $(viewInstance.el) ).masonry 'reloadItems'

      AlumNet.mainRegion.show(appliedJobsView)
      AlumNet.execute('render:job_exchange:submenu', undefined, 3)