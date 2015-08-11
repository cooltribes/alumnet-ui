@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

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
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
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
      @trigger "search", query  
      

    clear: (e)->
      e.preventDefault()
      @collection.fetch()  


  class Discover.Company extends Marionette.ItemView
    template: 'companies/discover/templates/company'

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
    childView: Discover.Company
    childViewContainer: '#companies-container'

    getTemplate: ()-> #Get the template based on the "type" property of the view
      if @type == "cards"
        'companies/discover/templates/gridContainer'
      else if @type == "list"
        'companies/discover/templates/tableContainer'

    childViewOptions: (model, index)->
      #initially for cards view
      tagName = 'div'
      template = "companies/discover/templates/_card"
      className = "col-md-4 margin_bottom_small"

      if @type == "list"
        tagName = 'tr'
        template = "companies/discover/templates/_row"
        className = ""


      className: className
      tagName: tagName
      template: template
    

    initialize: ()->
      @type = "list" #default view
    
