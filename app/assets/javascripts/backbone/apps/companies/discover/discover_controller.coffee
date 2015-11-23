@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller

    discover: ->
      AlumNet.execute('render:companies:submenu', undefined, 0)

      layout = @_getLayoutView()
      @list_view = @_getListView()

      AlumNet.mainRegion.show(layout)
      layout.companies_region.show(@list_view)
      list_view = @list_view


    myCompanies: ->
      AlumNet.execute('render:companies:submenu', undefined, 1)

      layout = @_getMyLayoutView()
      @list_view = @_getListView("my_companies")

      AlumNet.mainRegion.show(layout)
      layout.companies_region.show(@list_view)



    #For internal use
    _getLayoutView: ->
      view = new Discover.Layout

      view.on "search", @_applySearch, @
      view.on "advancedSearch", @_applyAdvancedSearch, @
      view.on "changeGrid", @_changeGrid, @

    _getMyLayoutView: ->
      view = new Discover.MyCompaniesLayout

      view.on "changeGrid", @_changeGrid, @


    _getListView: (layout = "")->
      controller = @
      controller.querySearch = {}
      companies = new AlumNet.Entities.CompaniesCollection
      companies.page = 1
      companies.url = AlumNet.api_endpoint + "/companies"
      if layout != "my_companies"
        companies.fetch
          data: { page: companies.page, per_page: companies.rows }
          reset: true
      else
        @querySearch = { q: { company_admins_user_id_eq: AlumNet.current_user.id, status_eq: 1 } }
        companies.fetch
          reset: true
          data:
            q:
              company_admins_user_id_eq: AlumNet.current_user.id
              status_eq: 1
            page: companies.page
            per_page: companies.rows

      view = new Discover.List
        collection: companies

      view.on "companies:reload", ->
        that = @
        querySearch = controller.querySearch
        newCollection = new AlumNet.Entities.CompaniesCollection
        newCollection.url = AlumNet.api_endpoint + '/companies'
        query = _.extend(querySearch, { page: ++@collection.page, per_page: @collection.rows })
        newCollection.fetch
          data: query
          success: (collection)->
            that.collection.add(collection.models)
            if collection.length < collection.rows
              that.endPagination()

      view.on "add:child", (viewInstance)->
        container = $('#companies-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
        container.append( $(viewInstance.el) ).masonry 'reloadItems'
      view


    _changeGrid: (type)->
      @list_view.type = type
      @list_view.render()


    _applySearch: (query)->
      @querySearch = query
      @list_view.collection.fetch
        data: query
        success: (collection)->
          container = $('#companies-container')
          container.masonry 'layout'

    _applyAdvancedSearch: (query)->
      @querySearch = query
      @list_view.collection.fetch
        data: { q: query }
        success: (collection)->
          container = $('#companies-container')
          container.masonry 'layout'
