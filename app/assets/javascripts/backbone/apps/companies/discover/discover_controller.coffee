@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller

    discover: ->
      AlumNet.execute('render:companies:submenu', undefined, 0)

      layout = @_getLayoutView()     
      @list_view = @_getListView()

      AlumNet.mainRegion.show(layout)
      layout.companies_region.show(@list_view)

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
      view.on "changeGrid", @_changeGrid, @

    _getMyLayoutView: ->
      view = new Discover.MyCompaniesLayout

      view.on "changeGrid", @_changeGrid, @


    _getListView: (layout = "")->
      companies = new AlumNet.Entities.CompaniesCollection
      if layout != "my_companies"
        companies.fetch()         
      else
        # companies.fetch()         
        companies.fetch
          data: 
            q:
              m: "and"
              company_admins_user_id_eq: AlumNet.current_user.id
              status_eq: 1


      view = new Discover.List
        collection: companies
      view
    

    _changeGrid: (type)->
      @list_view.type = type
      @list_view.render()


    _applySearch: (query)->
      @list_view.collection.fetch
        data: query

