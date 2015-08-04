@AlumNet.module 'JobExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/discover_task'
    className: 'col-md-4'

  class Discover.List extends Marionette.CompositeView
    template: 'job_exchange/discover/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "city_name", type: "string", values: "" },
        { attribute: "country_name", type: "string", values: "" },
        { attribute: "task_attributes_value", type: "string", values: "" }
      ])

    events:
      'click .add-new-filter': 'addNewFilter'
      #'click .js-search': 'search'
      'click .search': 'search'
      'click .clear': 'clear'
      'change #filter-logic-operator': 'changeOperator'

    changeOperator: (e)->
      e.preventDefault()
      if $(e.currentTarget).val() == "any"
        @searcher.activateOr = false
      else
        @searcher.activateOr = true

    addNewFilter: (e)->
      e.preventDefault()
      @searcher.addNewFilter()

    search: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      value = $('#search_term').val()      
      @collection.fetch
        data: { q: query }
        #data: { q: { name_cont: value } }
        

    clear: (e)->
      e.preventDefault()
      @collection.fetch()
