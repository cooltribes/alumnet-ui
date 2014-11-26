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
    template: 'groups/discover/templates/group'
    className: 'col-md-4 col-sm-6 col-xs-12'
    events:
      'click .js-group':'showGroup'
      'click .js-join':'sendJoin'
      'mouseenter .group-image-container': 'showSubGroups'
      'mouseleave .group-image-container': 'hideSubGroups'

    sendJoin: (e)->
      e.preventDefault()
      @trigger 'join'

    showGroup: (e)->
      e.preventDefault()
      @trigger 'group:show'

    showSubGroups: (e)->
      #todo: user currentTarget
      this.$el.find('.group-image-container').children('.overlay-subgroups').fadeIn()

    hideSubGroups: (e)->
      this.$el.find('.group-image-container').children('.overlay-subgroups').fadeOut()


  class Discover.GroupsView extends Marionette.CompositeView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'groups/discover/templates/groups_container'
    childView: Discover.GroupView
    childViewContainer: ".main-groups-area"
