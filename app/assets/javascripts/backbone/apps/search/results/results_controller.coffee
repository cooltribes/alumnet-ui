@AlumNet.module 'SearchApp.Results', (Results, @AlumNet, Backbone, Marionette, $, _) ->

  class Results.Controller
    show: (search_term)->
      controller = @
      controller.search_term = search_term ? {}
      
      @results_collection = new AlumNet.Entities.SearchResultCollection null

      @results_collection.search(search_term, {reset: true, remove: true})
      
      layoutView = @_getLayoutView()
      ###
      results_view = @_getResultsView()
      filters_view = @_getFiltersView()
      ###      

      AlumNet.mainRegion.show(layoutView)

      layoutView.results.show(@_getResultsView())
      layoutView.filters.show(@_getFiltersView())
      

    #For internal use
    _getLayoutView: ->
      view = new Results.Layout
        search_term: @search_term

      #when type of result has changed by user
      view.on "filter_type", (type)->
        view.filters.show(@_getFiltersView(type))
        @results_collection.search_by_type(type)
      , @  
          

    _getResultsView: ->
      view = new Results.ResultsListView
        collection: @results_collection
    

    _getFiltersView: (type = "all")->
      view = @_getEmptyFiltersView()            
      if type == "profile"
        view = new AlumNet.Shared.Views.Filters.Profiles.General
          results_collection: @results_collection     
      if type == "group"
        view = new AlumNet.Shared.Views.Filters.Groups.General
          results_collection: @results_collection     
      if type == "event"
        view = new AlumNet.Shared.Views.Filters.Events.General
          results_collection: @results_collection     
      if type == "company"
        view = new AlumNet.Shared.Views.Filters.Companies.General
          results_collection: @results_collection     
      if type == "task"
        view = new AlumNet.Shared.Views.Filters.Tasks.General
          results_collection: @results_collection     
      if type == "all"
        view = new AlumNet.Shared.Views.Filters.All.General
          results_collection: @results_collection     

      view    
    

    _getEmptyFiltersView: ->    
      view = new Results.EmptyView
        for_filters: true
        message: "Filter only specific type of result"
    
  