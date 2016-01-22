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

    showMenuUrl: (optionMenu)->
      self = @
      switch optionMenu
        when "newGroup"
          self.showcreateGroup()
      #   when "myGroups"
      #     self.showMyGroups()
      #   when "groupsDiscover"
      #     self.discoverGroups()

    
        