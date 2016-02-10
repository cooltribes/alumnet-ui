@AlumNet.module 'JobExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.Task extends AlumNet.Shared.Views.JobExchange.Task
    template: 'job_exchange/_shared/templates/discover_task'
    className: 'col-lg-6 col-md-6 col-sm-6 col-xs-12'

  class Discover.EmptyView extends Marionette.ItemView
    template: 'job_exchange/discover/templates/empty'

  class Discover.List extends Marionette.CompositeView
    emptyView: Discover.EmptyView
    template: 'job_exchange/discover/templates/discover_container'
    childView: Discover.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreJobs')      
      $(window).scroll(@loadMoreJobs)
      $("#iconModalJob").removeClass("hide")
      
    remove: ->
      @collection.page = 1
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @collection.page = 1
      @ui.loading.hide()
      $(window).unbind('scroll') 

    loadMoreJobs: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @trigger 'job:reload'

    onShow: ->
      seniorities =  @fetch_and_format_seniorities()
      employment_types =  AlumNet.Entities.Tasks.EMPLOYMENT_TYPES
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
        { attribute: "city_name", type: "string", values: "" },
        { attribute: "country_name", type: "string", values: "" },
        { attribute: "task_attributes_value", type: "string", values: "" }
        { attribute: "employment_type", type: "option", values: employment_types }
        { attribute: "seniority_id", type: "option", values: seniorities }
      ])

    fetch_and_format_seniorities: ->
      seniorities = new AlumNet.Utilities.Seniorities
      seniorities.fetch()
      _.map seniorities.results, (senority)->
        { value: senority.id,  text: senority.name }

    ui:
      'loading': '.throbber-loader'

    events:
      'click .add-new-filter': 'addNewFilter'
      'click .js-search': 'search'
      'click .search': 'searchadvance'
      'click .clear': 'clear'
      'change #filter-logic-operator': 'changeOperator'
      'click #js-advance':'showBoxAdvanceSearch'
      'click #js-basic' : 'showBoxAdvanceBasic'

    showBoxAdvanceSearch: (e)->
      e.preventDefault()
      $("#js-advance-search").slideToggle("slow")
      $("#search-form").slideToggle("hide");

    showBoxAdvanceBasic: (e)->
      e.preventDefault()
      $("#search-form").slideToggle("slow");
      $("#js-advance-search").slideToggle("hide")

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

    searchadvance: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      @collection.fetch
        data: { q: query }
        #data: { q: { name_cont: value } }

    clear: (e)->
      e.preventDefault()
      @collection.fetch()
      @searcher.clearFilters()