@AlumNet.module 'JobExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Controller
    automatches: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.page = 1
      tasks.url = AlumNet.api_endpoint + '/job_exchanges/automatches?page='+tasks.page+'&per_page='+tasks.rows  
      tasks.fetch
        reset: true
      automatchesView = new AutoMatches.List
        collection: tasks

      automatchesView.on "job:reload", ->
        ++automatchesView.collection.page
        newCollection = new AlumNet.Entities.JobExchangeCollection
        newCollection.url = AlumNet.api_endpoint + '/job_exchanges/automatches?page='+automatchesView.collection.page+'&per_page='+automatchesView.collection.rows
        newCollection.fetch
          success: (collection)->
            automatchesView.collection.add(collection.models)

      automatchesView.on "add:child", (viewInstance)->
        container = $('#tasks-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'        
          container.append( $(viewInstance.el) ).masonry 'reloadItems'

      AlumNet.mainRegion.show(automatchesView)
      #AlumNet.execute('render:job_exchange:submenu', undefined, 1)
