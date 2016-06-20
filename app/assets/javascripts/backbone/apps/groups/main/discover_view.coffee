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
        'groups/main/templates/_group_card'
      else if @type == "list"
        'groups/main/templates/_group_list'

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
    template: 'groups/main/templates/empty_discover'

  class Discover.GroupsView extends Marionette.CompositeView
    emptyView: Discover.EmptyView
    className: 'ng-scope'
    idName: 'wrapper'
    childView: Discover.GroupView
    childViewContainer: ".main-groups-area"

    ui:
      'loading': '.throbber-loader'

    getTemplate: ()-> #Get the template of the groups based on the "type" property of the view
      if @type == "cards"
        'groups/main/templates/groups_container_card'
      else if @type == "list"
        'groups/main/templates/groups_container_list'

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
      @parentView = options.parentView
      @type = options.typeGroup

      @on 'childview:group:show', (childView)->
        id = childView.model.id
        AlumNet.trigger "groups:posts", id

      @on 'childview:join', (childView) ->
        group = childView.model
        attrs = { group_id: group.get('id'), user_id: AlumNet.current_user.id }
        request = AlumNet.request('membership:create', attrs)
        request.on 'save:success', (response, options)->
          if group.isClose()
            AlumNet.trigger "groups:about", group.get('id')
          else
            AlumNet.trigger "groups:posts", group.get('id')

    onRender: ->
      $(window).unbind('scroll')
      _.bindAll(this, 'loadMoreGroups')
      $(window).scroll(@loadMoreGroups)
      $("#iconsTypeGroups").removeClass("hide")

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

    loadMoreGroups: (e)->
      if $(window).scrollTop()!=0 && $(window).scrollTop() == $(document).height() - $(window).height()
        @reloadItems()

    reloadItems: ->
      search_options =
        page: @collection.nextPage
        remove: false
        reset: false
      @collection.search_by_last_query(search_options)
