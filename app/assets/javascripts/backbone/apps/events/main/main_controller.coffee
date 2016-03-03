@AlumNet.module 'EventsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverEvents"

    showMainEvents: (optionMenu, current_user)->
      @activeTab = optionMenu
      @layoutEvents = new Main.EventsView
        option: @activeTab
      AlumNet.mainRegion.show(@layoutEvents)
      @showMenuUrl()

      self = @
      @layoutEvents.on "navigate:menu:events", (valueClick, current_user)->
        self.activeTab = valueClick
        self.showMenuUrl()

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
      @showFilters()

    showMyEvents: ->
      AlumNet.navigate("events/manage")
      events = new AlumNet.Entities.EventsCollection null,
        eventable: 'users'
        eventable_id: AlumNet.current_user.id
      query = { per_page: 1 }

      eventsView = new AlumNet.EventsApp.Manage.EventsView
        collection: events
        parentView: @layoutEvents
        query: query

      @layoutEvents.events_region.show(eventsView)

    showFilters: ->
      filters = new AlumNet.Shared.Views.Filters.Events.General
        results_collection: @results
      @layoutEvents.filters_region.show(filters)

    showMenuUrl: ->
      self = @
      switch @activeTab
        when "discoverEvents"
          self.showDiscoverEvents()
        when "myEvents"
          self.showMyEvents()
