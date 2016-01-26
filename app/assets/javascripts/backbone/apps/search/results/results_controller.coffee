@AlumNet.module 'SearchApp.Results', (Results, @AlumNet, Backbone, Marionette, $, _) ->

  class Results.Controller
    show: (search_term)->
      controller = @
      controller.search_term = search_term ? {}
      
      @results_collection = new AlumNet.Entities.SearchResultCollection null,
        search_term: search_term

      @results_collection.search()
      
      layoutView = @_getLayoutView()
      ###
      results_view = @_getResultsView()
      filters_view = @_getFiltersView()
      ###
      

      AlumNet.mainRegion.show(layoutView)

      layoutView.results.show(@_getResultsView())
      layoutView.filters.show(@_getEmptyFiltersView())
      
    #For internal use
    _getLayoutView: ->
      view = new Results.Layout
        search_term: @search_term

      #when type of result has changed by user
      view.on "filter_type", (type)->
        @results_collection.search(type)
        
        # only show filters when "Alumni" selected
        if type == "profile"          
          view.filters.show(@_getFiltersView())
        else  
          view.filters.show(@_getEmptyFiltersView())

      , @  
          
    _getResultsView: ->
      view = new Results.ResultsListView
        collection: @results_collection
    

    _getFiltersView: ->
      view = new AlumNet.Shared.Views.Filters.Layout   
        results_collection: @results_collection     
    
    _getEmptyFiltersView: ->    
      view = new Results.EmptyView
        for_filters: true
        message: "Filters only available for Alumni"
    
  