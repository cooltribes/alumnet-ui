@AlumNet.module 'GroupsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    showMainGroups: (optionMenu)->
      @layoutGroups = new Main.GroupsView
        option: optionMenu
      AlumNet.mainRegion.show(@layoutGroups)
      @showMenuUrl(optionMenu)
      @showSuggestionsGroups(optionMenu)
      current_user = AlumNet.current_user
      self = @

      @layoutGroups.on "click:type", (typeGroups)->
        self.showDiscoverGroups(typeGroups)

      @layoutGroups.on "navigate:menu:groups", (valueClick)->
        self.showMenuUrl(valueClick)

      @layoutGroups.on "navigate:menuRight", (valueClick)->
        switch valueClick
          when "suggestions"
            self.showSuggestionsGroups()
          when "filters"
            self.showFilters()

      # @layoutGroups.on 'groups:search', (querySearch)->
      #     self.querySearch = querySearch
      #     searchedGroups = AlumNet.request("group:entities", querySearch)

      @layoutGroups.on 'groups:search', (querySearch, collection)->
        collection.search(querySearch)

    showSuggestionsGroups: (optionMenu) ->
      model = new Backbone.Model
      if optionMenu != "groupsDiscover"
        model.set "showDiscover", true
      else
        model.set "showDiscover", false

      suggestions = new AlumNet.GroupsApp.Suggestions.GroupsView
        model: model
      collection = new AlumNet.Entities.SuggestedGroupsCollection
      collection.fetch
        success: (collection)->
          array_groups = collection.where(membership_status: "none")
          collection_groups = new AlumNet.Entities.SuggestedGroupsCollection(array_groups)
          suggestions.collection = collection_groups
          suggestions.render()

      @layoutGroups.filters_region.show(suggestions)

      suggestions.on 'childview:join', (childView) ->
        group = childView.model
        attrs = { group_id: group.get('id'), user_id: AlumNet.current_user.id }
        request = AlumNet.request('membership:create', attrs)
        request.on 'save:success', (response, options)->
          if group.isClose()
            AlumNet.trigger "groups:about", group.get('id')
          else
            AlumNet.trigger "groups:posts", group.get('id')

    showFilters: ()->
      controller = @
      filters = new AlumNet.Shared.Views.Filters.Groups.General
        results_collection: controller.groups
      #filters = new AlumNet.FriendsApp.Filters.FriendsView
      @layoutGroups.filters_region.show(filters)

    showDiscoverGroups: (type) ->
      AlumNet.navigate("groups/discover")
      controller = @
      controller.querySearch = {}
      controller.groups = new AlumNet.Entities.SearchResultCollection null,
        type: 'group'
      controller.groups.model = AlumNet.Entities.Group
      controller.groups.url = AlumNet.api_endpoint + '/groups/search'
      controller.groups.search()
      groupsView = @getContainerView(controller.groups, type)

      @layoutGroups.groups_region.show(groupsView)

      # events for paginate
      groupsView.on "group:reload", ->
        querySearch = controller.querySearch
        newCollection = AlumNet.request("group:pagination")
        newCollection.url = AlumNet.api_endpoint + '/groups'
        query = _.extend(querySearch, { page: ++groupsView.collection.page, per_page: groupsView.collection.rows })
        newCollection.fetch
          data: query
          success: (collection)->
            groupsView.collection.add(collection.models)
            if collection.length < collection.rows
              groupsView.endPagination()

      groupsView.on "add:child", (viewInstance)->
        container = $('#groups_container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.group_children'
        container.append( $(viewInstance.el) ).masonry({itemSelector: '.group_children'}).masonry 'reloadItems'

      groupsView.on 'childview:group:show', (childView)->
        id = childView.model.id
        AlumNet.trigger "groups:posts", id

      #When join link is clicked
      groupsView.on 'childview:join', (childView) ->
        group = childView.model
        attrs = { group_id: group.get('id'), user_id: AlumNet.current_user.id }
        request = AlumNet.request('membership:create', attrs)
        request.on 'save:success', (response, options)->
          if group.isClose()
            AlumNet.trigger "groups:about", group.get('id')
          else
            AlumNet.trigger "groups:posts", group.get('id')

    getContainerView: (groups, type) ->
      new AlumNet.GroupsApp.Discover.GroupsView
        collection: groups
        typeGroup: type

    showMyGroups: ->
      AlumNet.navigate("groups/my_groups")
      current_user = AlumNet.current_user
      groups = AlumNet.request("membership:groups", current_user.id, {})
      groupsView = new AlumNet.GroupsApp.Groups.GroupsView
        collection: groups
      @layoutGroups.groups_region.show(groupsView)

      groupsView.on 'childview:click:leave', (childView)->
        membership = AlumNet.request("membership:destroy", childView.model)

    showManageGroups:->
      AlumNet.navigate("groups/manage")
      current_user = AlumNet.current_user
      groups = AlumNet.request("membership:created_groups", current_user.id, {})
      groupsView = new AlumNet.GroupsApp.Groups.GroupsView
        collection: groups
      @layoutGroups.groups_region.show(groupsView)

      groupsView.on 'childview:click:leave', (childView)->
        membership = AlumNet.request("membership:destroy", childView.model)

    showMenuUrl: (optionMenu)->
      self = @
      switch optionMenu
        when "groupsDiscover"
          self.showDiscoverGroups("cards")
        when "myGroups"
          self.showMyGroups()
        when "groupsManage"
          self.showManageGroups()
      @showSuggestionsGroups(optionMenu)



