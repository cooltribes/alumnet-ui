@AlumNet.module 'JobExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.page = 1
      tasks.url = AlumNet.api_endpoint + '/job_exchanges?page='+tasks.page+'&per_page='+tasks.rows
      tasks.fetch
      	reset: true

      discoverView = new Discover.List
        collection: tasks

      discoverView.on "job:reload", ->
        ++discoverView.collection.page
        newCollection = new AlumNet.Entities.JobExchangeCollection
        newCollection.url = AlumNet.api_endpoint + '/job_exchanges?page='+discoverView.collection.page+'&per_page='+discoverView.collection.rows
        newCollection.fetch
          success: (collection)->
            discoverView.collection.add(collection.models)

      checkNewPost = false #flag for new posts

      discoverView.on "add:child", (viewInstance)->
        container = $('#tasks-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
        if checkNewPost
          container.prepend( $(viewInstance.el) ).masonry 'reloadItems'
          container.imagesLoaded ->
            container.masonry 'layout'
        else
          container.append( $(viewInstance.el) ).masonry 'reloadItems'
        checkNewPost = false
      # attach events

      AlumNet.mainRegion.show(discoverView)

      # Check cookies for first visit
      if not Cookies.get('job_exchange_visit')
        modal = new Discover.ModalJob
        $('#container-modal-job').html(modal.render().el)
        Cookies.set('job_exchange_visit', 'true')

      AlumNet.execute('render:job_exchange:submenu', undefined, 2)
