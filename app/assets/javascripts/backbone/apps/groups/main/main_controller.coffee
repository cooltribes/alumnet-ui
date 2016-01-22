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

    showMenuUrl: (optionMenu)->
      self = @
      # switch optionMenu
      #   when "newGroup"
      #     self.showcreateGroup()
      #   when "myGroups"
      #     self.showMyGroups()
      #   when "groupsDiscover"
      #     self.discoverGroups()

    
        