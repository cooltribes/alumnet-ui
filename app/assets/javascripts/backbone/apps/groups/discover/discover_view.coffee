@AlumNet.module 'GroupsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.GroupView extends Marionette.ItemView
    tagName: 'div'

    events:
      'click .js-join':'sendJoin'
      'click #js-subgroups': 'showSubgroups'

    modelEvents:
      'change': 'renderView'

    ui:
      'groupCard': '.groupCard__atribute__container'
      'groupCardOdd': '.groupCard__atribute__container--odd'
      'description':'#js-description'

    getTemplate: ()-> #Get the template of the groups based on the "type" property of the view
      if @type == "cards"
        'groups/discover/templates/group'
      else if @type == "list"
        'groups/discover/templates/groupList'

    initialize: (options)-> #get the options from the parent to select the template
      @type = options.type

    templateHelpers: ->
      userIsMember: @model.userIsMember()

    renderView: (e)->
      @render()

    sendJoin: (e)->
      e.preventDefault()
      @trigger 'join'
      model = @model
      @model.fetch
        success: ->
          model.trigger('renderView')
      @render()
      @trigger 'Catch:Up'

    onRender: ->
      @ui.groupCard.tooltip()
      @ui.groupCardOdd.tooltip()
      @ui.description.linkify()

    showSubgroups: (e)->
      id = $(e.currentTarget).attr("aria-controls")
      child = $(e.currentTarget).attr("data-child")
      $('#'+id).on('hidden.bs.collapse', () ->
        $('#js-subgroups').html("Show subgroups ("+child+")"))
      $('#'+id).on('shown.bs.collapse', () ->
        $('#js-subgroups').html("Hide subgroups ("+child+")"))


  class Discover.EmptyView extends Marionette.ItemView
    template: 'groups/discover/templates/empty'

  class Discover.GroupsView extends Marionette.CompositeView
    emptyView: Discover.EmptyView
    className: 'ng-scope'
    idName: 'wrapper'
    childView: Discover.GroupView
    childViewContainer: ".main-groups-area"

    getTemplate: ()-> #Get the template of the groups based on the "type" property of the view
      if @type == "cards"
        'groups/discover/templates/groups_container'
      else if @type == "list"
        'groups/discover/templates/groups_containerList'

    childViewOptions: (model, index)-> #Set the options for changineg the template of each itemView
      tagName = 'div'

      if @type == "list"
        tagName = 'tr'
        className = 'col-lg-12 col-md-12 col-xs-12'
        childViewContainer: ".main-groups-area"

      type: @type
      tagName: tagName
      #className: "group_children"

    initialize: (options) ->
      # Initialize the type of grid to use (cards or list)
      @querySearch = {}
      @type = options.typeGroup
      view = @
      @page = 1
      @collection.search({})

      # @collection.on 'fetch:success', ->
      #   view.official = @where({official: true})
      #   view.nonOfficial = @where({official: false})
      #   view.all = @slice()

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreGroups')
      $(window).scroll(@loadMoreGroups)
      $("#iconsTypeGroups").removeClass("hide");

    remove: ->
      $(window).unbind('scroll')
      @page = 1
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      @page = 1
      $(window).unbind('scroll')

    ui:
      'loading': '.throbber-loader'

    filterAll: (e)->
      e.preventDefault()
      @collection.reset(@all)

    filterOfficial: (e)->
      e.preventDefault()
      @collection.reset(@official)

    filterNonOfficial: (e)->
      e.preventDefault()
      @collection.reset(@nonOfficial)

    loadMoreGroups: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @reloadItems()

    reloadItems: ->
      search_options =
        search_term: ""
        page: ++@page
      @collection.search(search_options)
      # query = _.extend(@querySearch, { page: ++@collection.page, per_page: @collection.rows })
      # newCollection.fetch
      #   data: query
      #   success: (collection)->
      #     @collection.add(collection.models)
      #     if @collection.length < @collection.rows
      #       @endPagination()

      # newCollection = AlumNet.request("group:pagination")
      # newCollection.url = AlumNet.api_endpoint + '/groups'
      # query = _.extend(@querySearch, { page: ++@collection.page, per_page: @collection.rows })
      # newCollection.fetch
      #   data: query
      #   success: (collection)->
      #     @collection.add(collection.models)
      #     if @collection.length < @collection.rows
      #       @endPagination()
