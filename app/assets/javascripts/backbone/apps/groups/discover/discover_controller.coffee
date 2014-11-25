@AlumNet.module 'GroupsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.Controller
    discoverGroups: ->
      groups = AlumNet.request("group:entities", {})
      groupsView = @getContainerView(groups)
      searchView = @getHeaderView()

      layoutView = @getLayoutView()

      AlumNet.mainRegion.show(layoutView)

      layoutView.header_region.show(searchView)

      layoutView.list_region.show(groupsView)

      AlumNet.execute('render:group:submenu')

      # attach events
      searchView.on 'groups:search', (querySearch)->
        searchedGroups = AlumNet.request("group:entities", querySearch)

      groupsView.on 'childview:group:show', (childView)->
        id = childView.model.id
        AlumNet.trigger "groups:posts", id

      #When join link is clicked
      groupsView.on 'childview:join', (childView) ->
        group_id = { group_id: childView.model.get('id') }
        join = AlumNet.request('membership:request', group_id)
        join.on 'save:success', (response, options)->
          console.log response.responseJSON

        join.on 'save:error', (response, options)->
          console.log response.responseJSON

    getLayoutView: ->
      # List.Layout is in the same module but defined in list_view.coffee file
      new Discover.Layout

    # instantiate views defined in list_view.coffee
    getHeaderView: ->
      new Discover.HeaderView

    getContainerView: (groups) ->
      new Discover.GroupsView
        collection: groups