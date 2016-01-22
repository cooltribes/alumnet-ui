@AlumNet.module 'GroupsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    showMainGroups: (optionMenu)->
      @selectedMenu = optionMenu
      @layoutGroups = new Main.GroupsView
      AlumNet.mainRegion.show(@layoutGroups)
      @showMenuUrl(optionMenu)
      @showSuggestionsGroups()
      current_user = AlumNet.current_user
      self = @
      @layoutGroups.on "navigate:menu:groups", (valueClick)-> 
        self.selectedMenu = valueClick 
        self.showMenuUrl(valueClick)
      @layoutGroups.on "navigate:menuRight", (valueClick)->
        switch valueClick
          when "suggestions"
            self.showSuggestionsGroups()
          # when "filters"
          #   self.showFilters()

      @layoutGroups.on 'groups:search', (querySearch)->
        # if self.selectedMenu == "groupsDiscover"
          self.querySearch = querySearch
          searchedGroups = AlumNet.request("group:entities", querySearch)
        # else if self.selectedMenu == "myGroups"
        #   self.querySearch = querySearch
        #   searchedGroups = AlumNet.request("membership:groups", current_user.id, querySearch)


    showSuggestionsGroups: ->
      suggestions = new AlumNet.GroupsApp.Suggestions.GroupsView
      collection = new AlumNet.Entities.SuggestedGroupsCollection
      collection.fetch
        success: (collection)->
          array_groups = collection.where(membership_status: "none")
          collection_groups = new AlumNet.Entities.SuggestedGroupsCollection(array_groups)
          suggestions.collection = collection_groups
          suggestions.render()

      @layoutGroups.filters_region.show(suggestions)

    showDiscoverGroups: ->
      AlumNet.navigate("groups/discover")
      controller = @
      controller.querySearch = {}
      groups = AlumNet.request("group:entities", {})
      groupsView = @getContainerView(groups)

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

      checkNewPost = false #flag for new posts
      groupsView.on "add:child", (viewInstance)->
        container = $('#groups_container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.group_children'
        if checkNewPost
          container.prepend( $(viewInstance.el) ).masonry 'reloadItems'
          container.imagesLoaded ->
            container.masonry 'layout'
        else
          container.append( $(viewInstance.el) ).masonry 'reloadItems'
        checkNewPost = false

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

        request.on 'save:error', (response, options)->
          console.log response.responseJSON

    getContainerView: (groups) ->
      new AlumNet.GroupsApp.Discover.GroupsView
        collection: groups

    showMyGroups: ->
      AlumNet.navigate("groups/my_groups")
      current_user = AlumNet.current_user
      groups = AlumNet.request("membership:groups", current_user.id, {})
      groupsView = new AlumNet.GroupsApp.Groups.GroupsView
        collection: groups
      @layoutGroups.groups_region.show(groupsView)

      groupsView.on 'childview:click:leave', (childView)->
        membership = AlumNet.request("membership:destroy", childView.model)
        membership.on 'destroy:success', ->
          console.log "Destroy Ok"

    showcreateGroup: ->
      AlumNet.navigate("groups/new")
      current_user = AlumNet.current_user
      group = AlumNet.request("group:new")
      createForm = new AlumNet.GroupsApp.Create.GroupForm
        model: group
        user: current_user

      @layoutGroups.groups_region.show(createForm)
      createForm.on "form:submit", (model, data)->
        if model.isValid(true)
          options_for_save =
            wait: true
            contentType: false
            processData: false
            data: data
            success: (model, response, options)->
              createForm.picture_ids = []
              AlumNet.trigger "groups:invite", model.id
            error: (model, response, options)->
              $.growl.error({ message: response.responseJSON.message })
          model.save(data, options_for_save)

    showManageGroups:->
      AlumNet.navigate("groups/manage")
      current_user = AlumNet.current_user
      groups = AlumNet.request("membership:groups", current_user.id, {})
      groupsView = new AlumNet.GroupsApp.Groups.GroupsView
        collection: groups
      @layoutGroups.groups_region.show(groupsView)

      groupsView.on 'childview:click:leave', (childView)->
        membership = AlumNet.request("membership:destroy", childView.model)
        membership.on 'destroy:success', ->
          console.log "Destroy Ok"

    showMenuUrl: (optionMenu)->
      self = @
      switch optionMenu
        when "groupsDiscover"
          self.showDiscoverGroups()
        when "myGroups"
          self.showMyGroups()
        when "groupsManage"
          self.showManageGroups()
        when "newGroup"
          self.showcreateGroup()

    
        