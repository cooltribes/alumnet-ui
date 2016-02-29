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
      @parentView = options.parentView
      @type = options.typeGroup
      view = @
      @collection.search()

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreGroups')
      $(window).scroll(@loadMoreGroups)
      $("#iconsTypeGroups").removeClass("hide");

    remove: ->
      $(window).unbind('scroll')
      Backbone.View.prototype.remove.call(this)

    endPagination: ->
      @ui.loading.hide()
      $(window).unbind('scroll')

    ui:
      'loading': '.throbber-loader'

    loadMoreGroups: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @reloadItems()

    reloadItems: ->
      search_term =  @parentView.currentSearchTerm
      nextPage = @collection.getCurrentPage() + 1
      search_options =
        page: nextPage
        remove: false
        reset: false
      @collection.search_by_last_query(search_options)
