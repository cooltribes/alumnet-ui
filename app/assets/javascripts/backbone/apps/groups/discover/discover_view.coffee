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

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      this.trigger('groups:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        name_cont: searchTerm
        description_cont: searchTerm

  class Discover.GroupView extends Marionette.ItemView
    template: 'groups/discover/templates/groupList'
    tagName: 'tr'
    
    events:
      'click .js-join':'sendJoin'
    ui:
      'groupCard': '.groupCard__atribute__container'
      'groupCardOdd': '.groupCard__atribute__container--odd'
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
    template: 'groups/discover/templates/groups_containerList'
    childView: Discover.GroupView
    childViewContainer: ".groupTableView__List"
    initialize: ->
      @filterCollection(@collection)

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


