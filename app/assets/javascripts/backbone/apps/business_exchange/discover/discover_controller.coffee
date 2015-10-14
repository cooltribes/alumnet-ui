@AlumNet.module 'BusinessExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: (view = "people")->
      controller = @
      controller.querySearch = ''
      if view == "tasks"
        tasks = new AlumNet.Entities.BusinessExchangeCollection
        tasks.fetch()
        discoverView = new Discover.TasksList
          collection: tasks
      
      else if view == "people"
        profiles = new AlumNet.Entities.BusinessCollection
        profiles.page = 1
        profiles.url = AlumNet.api_endpoint + "/business?page="+profiles.page+"&per_page="+profiles.rows
        profiles.fetch
          reset: true
        discoverView = new Discover.ProfilesList
          collection: profiles 
      
      discoverView.on "business:reload", ->
        querySearch = controller.querySearch 
        ++discoverView.collection.page
        newCollection = new AlumNet.Entities.BusinessCollection
        newCollection.url = AlumNet.api_endpoint + '/business?page='+discoverView.collection.page+'&per_page='+discoverView.collection.rows
        newCollection.fetch
          data: querySearch
          success: (collection)->
            discoverView.collection.add(collection.models)

      discoverView.on "add:child", (viewInstance)->
        container = $('.profiles-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
          container.append( $(viewInstance.el) ).masonry 'reloadItems'
      
      discoverView.on 'business:search', (querySearch)->

        console.log "busquedas"
        controller.querySearch = querySearch
        discoverView.collection.fetch
          data: querySearch
          success: (collection)->
            console.log collection
            container = $('.profiles-container')
            container.masonry 'reloadItems'


      console.log view    
      console.log discoverView    
      
      discoverLayout = new Discover.Layout
        view: view

      AlumNet.mainRegion.show(discoverLayout)
      discoverLayout.content.show(discoverView)
      AlumNet.execute('render:business_exchange:submenu', undefined, 3)
