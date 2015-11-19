@AlumNet.module 'SearchApp.Results', (Results, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Results.Layout extends Marionette.LayoutView
    template: 'search/results/templates/layout'
    className: 'container'

    regions:
      results_region: '#results-region'

    initialize: (options)->
      @classes = {
        "all": " sortingMenu__item__link--active"
        "alumni": ""
      }

      @classes[options.view] = " sortingMenu__item__link--active"

    templateHelpers: ->
      active: (value)=>
        @classes[value]  

    
      
  class Results.ResultsView extends Marionette.CompositeView
    template: 'search/results/templates/layout'
    className: 'container-fluid'

    regions:
      results_region: '#results-region'

    
      
    