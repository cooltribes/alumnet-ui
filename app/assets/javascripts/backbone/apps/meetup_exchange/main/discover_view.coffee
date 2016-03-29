@AlumNet.module 'MeetupExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'col-md-6'
    template: 'meetup_exchange/_shared/templates/discover_task'

  class Discover.EmptyView extends Marionette.ItemView
    template: 'meetup_exchange/main/templates/empty_discover'

  class Discover.List extends Marionette.CompositeView
    emptyView: Discover.EmptyView
    template: 'meetup_exchange/main/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    onRender: ->
      $("#iconModalMeetup").removeClass("hide")

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "arrival_date", type: "numeric", values: "" },
        { attribute: "post_until", type: "numeric", values: "" },
        { attribute: "task_attributes_value", type: "string", values: "" }
      ])

    events:
      'click .add-new-filter': 'addNewFilter'
      'click .js-search': 'search'
      #'click .search': 'search'
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
        #data: { q: query }
        data: { q: { name_cont: value } }
        
    clear: (e)->
      e.preventDefault()
      @collection.fetch()
