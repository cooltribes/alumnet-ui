@AlumNet.module 'SearchApp.Results', (Results, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Results.Layout extends Marionette.LayoutView
    template: 'search/results/templates/layout'
    className: 'container'

    regions:
      results_region: '#results-region'

    initialize: (options)->
      console.log @collection
      @classes = {
        "all": " sortingMenu__item__link--active"
        "alumni": ""
      }

      @classes[options.view] = " sortingMenu__item__link--active"
      @search_term = options.search_term
        
    templateHelpers: ->
      active: (value)=>
        @classes[value]  
      search_term: @search_term    


  class Results.ResultView extends Marionette.CompositeView
    template: 'search/results/templates/_result'
  
      
  class Results.ResultsListView extends Marionette.CompositeView
    template: 'search/results/templates/results_list'
    childView: Results.ResultView
    emptyView: AlumNet.Utilities.EmptyView
    emptyViewOptions: 
      message: "There is no results for your search"
    childViewContainer: '.results-list'

    