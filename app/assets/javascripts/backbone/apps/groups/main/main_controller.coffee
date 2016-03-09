@AlumNet.module 'GroupsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    showMainGroups: (optionMenu)->
      @layoutGroups = new Main.GroupsView
        option: optionMenu
      AlumNet.mainRegion.show(@layoutGroups)
      @showMenuUrl(optionMenu)
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

    showSuggestionsGroups: (optionMenu) ->
      model = new Backbone.Model
      if optionMenu != "groupsDiscover"
        model.set "showDiscover", true
      else
        model.set "showDiscover", false

      initialCollection = new AlumNet.Entities.SuggestedGroupsCollection
      self = @
      initialCollection.fetch
        success: (collection)->
          array = collection.where(membership_status: "none")
          filteredGroups = new AlumNet.Entities.SuggestedGroupsCollection(array)
          suggestions = new AlumNet.GroupsApp.Suggestions.GroupsView
            model: model
            collection: filteredGroups

          self.layoutGroups.filters_region.show(suggestions)
          initialCollection = null

          suggestions.on 'childview:join', (childView) ->
            group = childView.model
            attrs = { group_id: group.get('id'), user_id: AlumNet.current_user.id }
            request = AlumNet.request('membership:create', attrs)
            request.on 'save:success', (response, options)->
              if group.isClose()
                AlumNet.trigger "groups:about", group.get('id')
              else
                AlumNet.trigger "groups:posts", group.get('id')

    showDiscoverGroups: (type) ->
      AlumNet.navigate("groups/discover")
      groups = AlumNet.request("results:groups")
      @results = groups

      groupsView = new AlumNet.GroupsApp.Discover.GroupsView
        collection: groups
        typeGroup: type
        parentView: @layoutGroups

      @layoutGroups.groups_region.show(groupsView)

      groupsView.on "add:child", (viewInstance)->
        container = $('#groups_container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.group_children'
        container.append( $(viewInstance.el) ).masonry({itemSelector: '.group_children'}).masonry 'reloadItems'

    showMyGroups: ->
      AlumNet.navigate("groups/my_groups")
      query = { per_page: 10 }
      groups = AlumNet.request("membership:groups", AlumNet.current_user.id, query)

      groupsView = new AlumNet.GroupsApp.Groups.GroupsView
        collection: groups
        parentView: @layoutGroups
        query: query

      @layoutGroups.groups_region.show(groupsView)


    showManageGroups:->
      AlumNet.navigate("groups/manage")
      query = { per_page: 10 }
      groups = AlumNet.request("membership:created_groups", AlumNet.current_user.id, query)

      groupsView = new AlumNet.GroupsApp.Groups.GroupsView
        collection: groups
        parentView: @layoutGroups
        query: query

      @layoutGroups.groups_region.show(groupsView)

    showFilters: ()->
      filters = new AlumNet.Shared.Views.Filters.Groups.General
        results_collection: @results
      @layoutGroups.filters_region.show(filters)

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



