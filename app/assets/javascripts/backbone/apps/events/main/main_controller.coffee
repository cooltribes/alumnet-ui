@AlumNet.module 'EventsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverEvents"

    showMainLayout: (optionMenu, current_user)->
      @activeTab = optionMenu
      @layoutEvents = new Main.EventsView
        option: @activeTab
      AlumNet.mainRegion.show(@layoutEvents)
      @showRegionMenu()

      self = @
      @layoutEvents.on "navigate:menu:left", (valueClick, current_user)->
        self.activeTab = valueClick
        self.showRegionMenu()

      @layoutEvents.on "navigate:menu:right", (valueClick)->
        switch valueClick
          when "suggestions"
            self.showSuggestions(self.activeTab)
          when "filters"
            self.showFilters()

      @layoutEvents.on 'events:search', (querySearch, collection)->
        collection.search(querySearch)

    showDiscoverEvents: ->
      AlumNet.navigate("events/discover")
      events = AlumNet.request("results:events")
      @results = events

      eventsView = new AlumNet.EventsApp.Discover.EventsView
        collection: events
        parentView: @layoutEvents

      @layoutEvents.events_region.show(eventsView)

    showMyEvents: ->
      AlumNet.navigate("events/my_events")
      events = new AlumNet.Entities.EventsCollection null,
        eventable: 'users'
        eventable_id: AlumNet.current_user.id
      query = { per_page: 10 }

      eventsView = new AlumNet.EventsApp.Manage.EventsView
        collection: events
        parentView: @layoutEvents
        query: query

      @layoutEvents.events_region.show(eventsView)

    showManageEvents: ->
      AlumNet.navigate("events/manage")
      events = new AlumNet.Entities.EventsCollection
      events.url = AlumNet.api_endpoint + "/me/events/managed"

      window.events = events
      query = { per_page: 10 }

      eventsView = new AlumNet.EventsApp.Manage.EventsView
        collection: events
        parentView: @layoutEvents
        query: query

      @layoutEvents.events_region.show(eventsView)

    showSuggestions: (optionMenuLeft)->
      collection = new AlumNet.Entities.SuggestedEventsCollection

      suggestionsView = new AlumNet.EventsApp.Suggestions.EventsView 
        collection: collection
        optionMenuLeft: optionMenuLeft
        
      @layoutEvents.filters_region.show(suggestionsView)

    showFilters: ->
      filters = new AlumNet.Shared.Views.Filters.Events.General
        results_collection: @results
      @layoutEvents.filters_region.show(filters)

    showRegionMenu: ->
      self = @
      switch @activeTab
        when "discoverEvents"
          self.showDiscoverEvents()
        when "myEvents"
          self.showMyEvents()
        when "manageEvents"
          self.showManageEvents()
      @showSuggestions(@activeTab)

