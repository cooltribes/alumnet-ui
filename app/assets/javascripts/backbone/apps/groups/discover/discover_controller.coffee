@AlumNet.module 'GroupsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->

  class Discover.Controller
    discoverGroups: ->
      groups = AlumNet.request("group:entities", {})
      groupsView = @getContainerView(groups)
      searchView = @getHeaderView(groupsView)

      layoutView = @getLayoutView()

      AlumNet.mainRegion.show(layoutView)

      layoutView.header_region.show(searchView)

      layoutView.list_region.show(groupsView)

      AlumNet.execute('render:groups:submenu',undefined, 1)

      # attach events
      searchView.on 'groups:search', (querySearch)->
        searchedGroups = AlumNet.request("group:entities", querySearch)

      groupsView.on 'childview:group:show', (childView)->
        id = childView.model.id
        AlumNet.trigger "groups:posts", id

      #When join link is clicked
      groupsView.on 'childview:join', (childView) ->
        group = childView.model
        attrs = { group_id: group.get('id'), user_id: AlumNet.current_user.id }
        request = AlumNet.request('membership:create', attrs)
        request.on 'save:success', (response, options)->
          console.log response.responseJSON
          AlumNet.trigger "groups:posts", group.get('id')
          @render()
          console.log group
        


        request.on 'save:error', (response, options)->
          console.log response.responseJSON

    getLayoutView: ->
      # List.Layout is in the same module but defined in list_view.coffee file
      new Discover.Layout

    # instantiate views defined in list_view.coffee
    getHeaderView: (groupsView)->
      new Discover.HeaderView
        groupsView: groupsView

    getContainerView: (groups) ->
      new Discover.GroupsView
        collection: groups