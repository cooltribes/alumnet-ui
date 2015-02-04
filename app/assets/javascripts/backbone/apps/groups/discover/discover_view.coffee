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

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      this.trigger('groups:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        name_cont: searchTerm
        description_cont: searchTerm

    ViewCard: ()->
      @groupsView.type = "cards"
      @groupsView.render()

    ViewList: ()->      
      @groupsView.type = "list"
      @groupsView.render()

  class Discover.GroupView extends Marionette.ItemView    
    tagName: 'div'
    className: 'col-md-4 col-sm-6 col-xs-12'
    events:
      'click .js-join':'sendJoin'
    ui:
      'groupCard': '.groupCard__atribute__container'
      'groupCardOdd': '.groupCard__atribute__container--odd'
    
    getTemplate: ()-> #Get the template of the groups based on the "type" property of the view
      if @type == "cards"
        'groups/discover/templates/group'
      else if @type == "list"
        'groups/discover/templates/groupList'
    
    initialize: (options)-> #get the options from the parent to select the template
      @type = options.type

    templateHelpers: ->
      userIsMember: @model.userIsMember()

    sendJoin: (e)->
      e.preventDefault()
      @trigger 'join'

    onRender: ->
      @ui.groupCard.tooltip()
      @ui.groupCardOdd.tooltip()

  class Discover.GroupsView extends Marionette.CompositeView
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
      
      type: @type
      tagName: tagName


    initialize: ->
      @filterCollection(@collection)
      #Initialize the type of grid to use (cards or list)
      @type = "cards"
      @type = "list"

    events:
      'click #js-filter-all': 'filterAll'
      'click #js-filter-official': 'filterOfficial'
      'click #js-filter-non-official': 'filterNonOfficial'

    filterAll: (e)->
      e.preventDefault()
      @collection.reset(@all)

    filterOfficial: (e)->
      e.preventDefault()
      @collection.reset(@official)

    filterNonOfficial: (e)->
      e.preventDefault()
      @collection.reset(@nonOfficial)

    filterCollection: (collection)->
      @official = collection.where({official: true})
      @nonOfficial = collection.where({official: false})
      @all = collection.slice()


