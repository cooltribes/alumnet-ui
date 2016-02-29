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



