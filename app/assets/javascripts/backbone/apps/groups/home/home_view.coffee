@AlumNet.module 'GroupsApp.Home', (Home, @AlumNet, Backbone, Marionette, $, _) ->

  class Home.Group extends Marionette.ItemView
    template: 'groups/home/templates/group'
    className: 'box'
    events:
      'click td': 'showDescription'
      'click .js-delete': 'deleteClicked'
      'click .js-show': 'showClicked'
      'mouseenter .group-image-container': 'showSubGroups'
      'mouseleave .group-image-container': 'hideSubGroups'
    remove: ->
      self = this
      this.$el.fadeOut ->
        Marionette.ItemView.prototype.remove.call(self)
    showDescription: ->
      alert this.model.escape('description')
    deleteClicked: (e)->
      e.stopPropagation()
      this.trigger('group:delete', this.model)
    showClicked: (e)->
      e.preventDefault()
      e.stopPropagation()
      this.trigger('group:show', this.model)
    showSubGroups: (e)->
      this.$el.find('.group-image-container').children('.overlay-subgroups').fadeIn()
    hideSubGroups: (e)->
      this.$el.find('.group-image-container').children('.overlay-subgroups').fadeOut()


  class Home.Groups extends Marionette.CompositeView
    className: 'ng-scope'
    idName: 'wrapper'
    template: 'groups/home/templates/groups_container'
    childView: Home.Group
    childViewContainer: ".main-groups-area"
    events:
      'click .js-search': 'performSearch'

    performSearch: (e) ->
      e.preventDefault()
      $searchForm = this.$el.find('form#search-form')
      data = Backbone.Syphon.serialize(this)
      this.trigger('group:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        name_cont: searchTerm
        description_cont: searchTerm


    # onChildviewGroupDelete: ->
    #   console.log "ahoy"