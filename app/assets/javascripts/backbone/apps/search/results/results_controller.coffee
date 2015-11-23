@AlumNet.module 'SearchApp.Results', (Results, @AlumNet, Backbone, Marionette, $, _) ->

  class Results.Controller
    show: (search_term)->
      controller = @
      controller.search_term = search_term ? {}
      
      layoutView = @_getLayoutView()
      
      AlumNet.mainRegion.show(layoutView)

      @results_collection = new AlumNet.Entities.SearchResultCollection null,
        search_term: search_term
      

      ###layoutView.header_region.show(searchView)

      layoutView.list_region.show(groupsView)###

      
    #For internal use
    _getLayoutView: ->
      view = new Results.Layout
        search_term: @search_term

     ### view.on "search", @_applySearch, @
      view.on "advancedSearch", @_applyAdvancedSearch, @
      view.on "changeGrid", @_changeGrid, @
###
    
    _getResultsView: ->
      view = new Results.ResultsListView
        collection: @results_collection
