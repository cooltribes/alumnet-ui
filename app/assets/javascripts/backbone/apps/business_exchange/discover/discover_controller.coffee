@AlumNet.module 'BusinessExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: (view = "people")->
      controller = @
      controller.querySearch = {}
      if view == "tasks"
        tasks = new AlumNet.Entities.BusinessExchangeCollection
        tasks.url = AlumNet.api_endpoint + "/business_exchanges?page="+tasks.page+"&per_page="+tasks.rows
        tasks.fetch
          reset: true
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
        if view == "tasks"
          newCollection = new AlumNet.Entities.BusinessExchangeCollection
          newCollection.url = AlumNet.api_endpoint + '/business_exchanges'
          query = _.extend(querySearch, { page: ++@collection.page, per_page: @collection.rows })
        else
          newCollection = new AlumNet.Entities.BusinessCollection
          newCollection.url = AlumNet.api_endpoint + '/business'
          query = _.extend(querySearch, { page: ++@collection.page, per_page: @collection.rows })
        newCollection.fetch
          data: query
          success: (collection)->
            discoverView.collection.add(collection.models)
            if collection.length < collection.rows
              discoverView.endPagination()

      discoverView.on "add:child", (viewInstance)->
        container = $('#business-exchange-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
        container.append( $(viewInstance.el) ).masonry().masonry 'reloadItems'

      discoverView.on 'business:search', (querySearch)->

        controller.querySearch = querySearch
        discoverView.collection.fetch
          data: querySearch
          success: (collection)->
            container = $('.profiles-container')
            container.masonry().masonry 'reloadItems'

      discoverLayout = new Discover.Layout
        view: view

      AlumNet.mainRegion.show(discoverLayout)
      discoverLayout.content.show(discoverView)
      #AlumNet.execute('render:business_exchange:submenu', undefined, 3)
