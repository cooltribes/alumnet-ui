@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller

    discover: ->
      AlumNet.execute('render:companies:submenu', undefined, 1)

      layout = @_getLayoutView()     
      @list_view = @_getListView()

      AlumNet.mainRegion.show(layout)
      layout.companies_region.show(@list_view)



    #For internal use
    _getLayoutView: ->
      view = new Discover.Layout

      view.on "search", @_applySearch, @
      view.on "changeGrid", @_changeGrid, @


    _getListView: ->
      companies = new AlumNet.Entities.CompaniesCollection
      companies.fetch() 

      view = new Discover.List
        collection: companies

      view
    

    _changeGrid: (type)->
      @list_view.type = type
      @list_view.render()


    _applySearch: (query)->
      @list_view.collection.fetch
        data: query

