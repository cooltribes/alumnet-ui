@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.EmptyView extends Marionette.ItemView
    template: 'companies/discover/templates/empty'

  class Discover.Layout extends Marionette.LayoutView
    template: 'companies/discover/templates/layout'
    className: 'container-fluid'

    regions:
      companies_region: '#companies-region'

    events:
      'click .add-new-filter': 'addNewFilter'
      'submit #search-form': 'basicSearch'
      'click .search': 'advancedSearch'
      'click .clear': 'clear'
      'change #filter-logic-operator': 'changeOperator'
      'click #js-advanced':'showAdvancedSearch'
      'click #js-basic' : 'showBasicSearch'
      'click .js-changeGrid' : 'changeGridView'

    onShow: ->
      sizes =  AlumNet.Entities.Company.sizes
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "country_name", type: "string", values: "" },
        { attribute: "sector_name", type: "string", values: "" },
        { attribute: "size", type: "option", values: sizes },
        { attribute: "product_services_name", type: "string", values: "" },
      ])

    changeGridView: (e)->
      e.preventDefault()
      element = $(e.currentTarget)
      element.siblings().removeClass("searchBar__renderOptions__iconActive")
      element.addClass("searchBar__renderOptions__iconActive")
      type = element.attr("data-grid")
      @trigger "changeGrid", type


    showAdvancedSearch: (e)->
      e.preventDefault()
      $("#search-form").fadeToggle "fast", "swing", ()->
        $("#js-advanced-search").fadeToggle("fast")

    showBasicSearch: (e)->
      e.preventDefault()
      $("#js-advanced-search").fadeToggle "fast", "swing", ()->
        $("#search-form").fadeToggle("fast")

    changeOperator: (e)->
      e.preventDefault()
      if $(e.currentTarget).val() == "any"
        @searcher.activateOr = false
      else
        @searcher.activateOr = true

    addNewFilter: (e)->
      e.preventDefault()
      @searcher.addNewFilter()

    basicSearch: (e)->
      e.preventDefault()
      value = $('#search_term').val()
      query =
        q: { name_cont: value }
      @trigger "search", query

    advancedSearch: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      @trigger "advancedSearch", query


    clear: (e)->
      e.preventDefault()
      @collection.fetch()


  class Discover.Company extends Marionette.ItemView
    template: 'companies/discover/templates/company'

    initialize: (options)->
      @type = options.type

    ui:
      'deleteLink': '.js-delete-company'

    events:
      'click @ui.deleteLink': 'deleteClicked'

    deleteClicked: (e)->
      e.preventDefault()
      @model.destroy
        wait: true
        error: (model, response) ->
          message = AlumNet.formatErrorsFromApi(response.responseJSON)
          $.growl.error(message: message)


    templateHelpers: ->
      model = @model
      console.log "discover model"
      console.log model
      userIsAdmin: @model.userIsAdmin()
      employees_count: @model.employees_count()
      branches_count: @model.branches_count()
      links_count: @model.links_count()
      linksCollection: @model.get('links')
      linksCollectionCount: @model.get('links').length
      location: ->
        location = []
        location.push(model.get("main_address")) unless model.get("main_address") == ""
        location.push(model.get("city").name) unless model.get("city").name == ""
        location.push(model.get("country").name) unless model.get("country").name == ""
        location.join(", ")

  class Discover.CompaniesView extends Marionette.CompositeView
    emptyView: Discover.EmptyView
    childView: Discover.Company
    childViewContainer: '#companies-container'

    getTemplate: ()-> #Get the template based on the "type" property of the view
      if @type == "cards"
        'companies/discover/templates/gridContainer'
      else if @type == "list"
        'companies/discover/templates/tableContainer'
    emptyViewOptions:
      template: 'companies/discover/templates/empty'

    childViewOptions: (model, index)->
      #initially for cards view

      tagName = 'div'
      template = "companies/discover/templates/_card"
      className = "col-xs-12 col-md-6 margin_bottom_small"

      if @type == "list"
        tagName = 'tr'
        template = "companies/discover/templates/_row"
        className = ""

      className: className
      tagName: tagName
      template: template
      type: @type

    ui:
      'loading': '.throbber-loader'

    templateHelpers: ()->
      collection = @collection

    initialize: (options)->
      @type = options.type
      @parentView = options.parentView
      @query = options.query

      ##this is a hack until all collection be an ResultCollection
      if @query
        @collection.fetch
          reset: true
          remove: true
          data: @query
      else
        @collection.search()

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreCompanies')
      $(window).scroll(@loadMoreCompanies)

    remove: ->
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()

    loadMoreCompanies: (e)->
      if @collection.nextPage == null
        @endPagination()
      else
        if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
          @reloadItems()

    reloadItems: ->
      if @query
        @query.page = @collection.nextPage
        @collection.fetch
          data: @query
          remove: false
          reset: false
      else
        search_options =
          page: @collection.nextPage
          remove: false
          reset: false
        @collection.search_by_last_query(search_options)

  class Discover.MyCompaniesLayout extends Marionette.LayoutView
    template: 'companies/discover/templates/my_companies_layout'
    className: 'container-fluid'

    regions:
      companies_region: '#companies-region'

    events:
      'click .js-changeGrid' : 'changeGridView'

    changeGridView: (e)->
      e.preventDefault()
      element = $(e.currentTarget)
      element.siblings().removeClass("searchBar__renderOptions__iconActive")
      element.addClass("searchBar__renderOptions__iconActive")
      @type = element.attr("data-grid")
      @trigger "changeGrid", @type
