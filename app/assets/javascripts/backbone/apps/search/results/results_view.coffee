@AlumNet.module 'SearchApp.Results', (Results, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Results.Layout extends Marionette.LayoutView
    template: 'search/results/templates/layout'
    className: 'container'

    regions:
      results: '#results-region'
      filters: '#filters-region'

    events:
      "click .js-typefilter": "filter_type"

    initialize: (options)->
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

    filter_type: (e)->
      e.preventDefault()
      target = $(e.currentTarget)
      
      @activateOption(target)

      @trigger "filter_type", target.attr("data-result-type")  

    activateOption: (element)->
      @$(".js-typefilter").removeClass("sortingMenu__item__link--active")
      element.addClass("sortingMenu__item__link--active")


  class Results.ResultView extends Marionette.CompositeView
    template: 'search/results/templates/_result'

    templateHelpers: ->
      industry: @model.getIndustry()
      image: @model.getImage()
      title: @model.getTitle()
      type: @model.getType()
      position: @model.getPosition()
      location: @model.getLocation()
      description: @model.getDescription()
      eventStart: @model.getEventStart()
      url: @model.getUrl()
      imageClass: @model.getImageClass()

  class Results.EmptyView extends Marionette.ItemView
    template: 'search/results/templates/_empty'  

    initialize: (options)->
      @message = options.message
      @for_filters = options.for_filters

    templateHelpers: ->
      message: @message   
      for_filters: @for_filters
      
      
  class Results.ResultsListView extends Marionette.CompositeView
    template: 'search/results/templates/results_list'
    childView: Results.ResultView
    childViewContainer: '.results-list'

    emptyView: Results.EmptyView
    emptyViewOptions: ->
      message: "There are no results for your search"
      for_filters: false