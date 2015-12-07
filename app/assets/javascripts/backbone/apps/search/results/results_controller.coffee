@AlumNet.module 'SearchApp.Results', (Results, @AlumNet, Backbone, Marionette, $, _) ->

  class Results.Controller
    show: (search_term)->
      controller = @
      controller.search_term = search_term ? {}
      
      @results_collection = new AlumNet.Entities.SearchResultCollection null,
        search_term: search_term
      @results_collection.fetch()
      console.log @results_collection

      layoutView = @_getLayoutView()
      results_view = @_getResultsView()

      AlumNet.mainRegion.show(layoutView)

      layoutView.results.show(results_view)
      
    #For internal use
    _getLayoutView: ->
      view = new Results.Layout
        search_term: @search_term

      view.on "filter_type", (type)->
        @results_collection.filter_type(type)
      , @  
          
    _getResultsView: ->
      view = new Results.ResultsListView
        collection: @results_collection
