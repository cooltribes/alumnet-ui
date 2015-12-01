@AlumNet.module 'GroupsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.Layout extends Marionette.LayoutView
    template: 'groups/discover/templates/layout'
    className: 'container-fluid'

    regions:
      header_region: '#groups-search-region'
      list_region:   '#groups-list-region'

  class Discover.HeaderView extends Marionette.LayoutView
    template: 'groups/discover/templates/groups_search'
    events:
      'click .js-search': 'performSearch'
      'click .js-viewCard': 'ViewCard'
      'click .js-viewList': 'ViewList'

    initialize: (options)->
      #View for showing the groups (class Discover.GroupsView)
      @groupsView = options.groupsView

    ui:
      'viewCard':'.main-groups-area'
      'viewList':'.groupTableView'

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      this.trigger('groups:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        name_cont: searchTerm
        description_cont: searchTerm

    ViewCard: (e)->
      $(e.currentTarget).addClass("searchBar__renderOptions__iconActive")
      $(e.currentTarget).siblings().removeClass("searchBar__renderOptions__iconActive")
      @groupsView.type = "cards"
      @groupsView.render()

    ViewList: (e)->
      $(e.currentTarget).addClass("searchBar__renderOptions__iconActive")
      $(e.currentTarget).siblings().removeClass("searchBar__renderOptions__iconActive")
      @groupsView.type = "list"
      @groupsView.render()

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

    initialize: (options)->
      #@listenTo(@model, 'change:sendJoin', @renderView)

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
        childViewContainer: ".main-groups-area"

      type: @type
      tagName: tagName
      #className: "group_children"

    initialize: ->
      # Initialize the type of grid to use (cards or list)
      @type = "cards"
      view = @
      @collection.on 'fetch:success', ->
        view.official = @where({official: true})
        view.nonOfficial = @where({official: false})
        view.all = @slice()

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreGroups')      
      $(window).scroll(@loadMoreGroups)

    remove: ->
      $(window).unbind('scroll')
      @collection.page = 1
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      @collection.page = 1
      $(window).unbind('scroll') 

    events:
      'click #js-filter-all': 'filterAll'
      'click #js-filter-official': 'filterOfficial'
      'click #js-filter-non-official': 'filterNonOfficial'
      
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
        @trigger 'group:reload'
