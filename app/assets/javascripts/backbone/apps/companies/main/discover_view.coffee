@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.EmptyView extends Marionette.ItemView
    template: 'companies/main/templates/empty_discover'

  class Discover.Company extends Marionette.ItemView
    template: 'companies/main/templates/company'

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

    getTemplate: -> #Get the template based on the "type" property of the view
      if @type == "cards"
        'companies/main/templates/gridContainer'
      else if @type == "list"
        'companies/main/templates/tableContainer'
    emptyViewOptions:
      template: 'companies/main/templates/empty_discover'

    childViewOptions: (model, index)->
      #initially for cards view

      tagName = 'div'
      template = "companies/main/templates/_card"
      className = "col-xs-12 col-md-6 margin_bottom_small"

      if @type == "list"
        tagName = 'tr'
        template = "companies/main/templates/_row"
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

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreCompanies')
      $(window).scroll(@loadMoreCompanies)

      ##this is a hack until all collection be an ResultCollection
      if @query
        @showLoading()
        @collection.fetch
          reset: true
          remove: true
          data: @query
      else
        @showLoading()
        @collection.search()

      @listenTo @collection, 'request', @showLoading
      @listenTo @collection, 'sync', @hideLoading

    showLoading: ->
      @ui.loading.show()

    hideLoading: ->
      @ui.loading.hide()

    remove: ->
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    loadMoreCompanies: (e)->
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