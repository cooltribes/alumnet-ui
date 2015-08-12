@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.Company extends Marionette.ItemView
    template: 'companies/discover/templates/company'
    className: 'col-md-4'

    templateHelpers: ->
      model = @model
      employees_count: @model.employees_count()
      branches_count: @model.branches_count()
      links_count: @model.links_count()
      location: ->
        location = []
        location.push(model.get("main_address")) unless model.get("main_address") == ""
        location.push(model.get("city").text) unless model.get("city").text == ""
        location.push(model.get("country").text) unless model.get("country").text == ""
        location.join(", ")

  class Discover.List extends Marionette.CompositeView
    template: 'companies/discover/templates/discover_container'
    childView: Discover.Company
    childViewContainer: '.companies-container'
    className: 'container-fluid'

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
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
      value = $('#search_term').val()
      @collection.fetch
        data: { q: query }


    clear: (e)->
      e.preventDefault()
      @collection.fetch()
