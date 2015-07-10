@AlumNet.module 'JobExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/discover_task'

  class Discover.List extends Marionette.CompositeView
    template: 'job_exchange/discover/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "city_name", type: "string", values: "" },
        { attribute: "country_name", type: "string", values: "" },
        { attribute: "task_attributes_value", type: "string", values: "" }
      ])

    events:
      'click .add-new-filter': 'addNewFilter'
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
      @collection.fetch
        data: { q: query }

    clear: (e)->
      e.preventDefault()
      @collection.fetch()
