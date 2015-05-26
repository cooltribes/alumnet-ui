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
      document.title='AlumNet - Discover Groups'
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
      @model.fetch()
      @model.render()

    sendJoin: (e)->
      e.preventDefault()
      @trigger 'join'
      @model.fetch()
      @render() 
      
    onRender: ->
      @ui.groupCard.tooltip()
      @ui.groupCardOdd.tooltip()
      @ui.description.linkify()

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

    initialize: ->
      # Initialize the type of grid to use (cards or list)
      @type = "cards"
      view = @
      @collection.on 'fetch:success', ->
        view.official = @where({official: true})
        view.nonOfficial = @where({official: false})
        view.all = @slice()

    events:
      'click #js-filter-all': 'filterAll'
      'click #js-filter-official': 'filterOfficial'
      'click #js-filter-non-official': 'filterNonOfficial'
    #'change': 'renderView'

    filterAll: (e)->
      e.preventDefault()
      console.log 'here All', @all
      @collection.reset(@all)

    filterOfficial: (e)->
      e.preventDefault()
      console.log 'here Off', @official
      @collection.reset(@official)

    filterNonOfficial: (e)->
      e.preventDefault()
      console.log 'here nOff', @nonOfficial
      @collection.reset(@nonOfficial)

    #renderView: ->
    #  @render()
