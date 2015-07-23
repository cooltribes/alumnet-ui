@AlumNet.module 'MeetupExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'col-md-4'
    template: 'meetup_exchange/_shared/templates/discover_task'

  class Discover.List extends Marionette.CompositeView
    template: 'meetup_exchange/discover/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'
    className: 'container'

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "arrival_date", type: "numeric", values: "" },
        { attribute: "post_until", type: "numeric", values: "" },
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