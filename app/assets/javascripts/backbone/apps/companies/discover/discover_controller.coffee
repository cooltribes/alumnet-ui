@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller

    discover: ->
      controller = @
      controller.querySearch = {}
      AlumNet.execute('render:companies:submenu', undefined, 0)

      layout = @_getLayoutView()
      @list_view = @_getListView()

      AlumNet.mainRegion.show(layout)
      layout.companies_region.show(@list_view)
      list_view = @list_view

      list_view.on "companies:reload", ->
        querySearch = controller.querySearch
        ++list_view.collection.page
        newCollection = new AlumNet.Entities.CompaniesCollection
        newCollection.url = AlumNet.api_endpoint + '/companies'
        query = _.extend(querySearch, { page: list_view.collection.page, per_page: list_view.collection.rows })
        newCollection.fetch
          data: query
          success: (collection)->
            list_view.collection.add(collection.models)

      list_view.on "add:child", (viewInstance)->
        container = $('#companies-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
        container.append( $(viewInstance.el) ).masonry 'reloadItems'

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
      companies = new AlumNet.Entities.CompaniesCollection
      companies.page = 1
      companies.url = AlumNet.api_endpoint + "/companies"
      if layout != "my_companies"
        companies.fetch
          data: { page: companies.page, per_page: companies.rows }
          reset: true
      else
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
