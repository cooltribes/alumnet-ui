@AlumNet.module 'EventsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverEvents"
    eventable_id: null
    showMainEvents: (optionMenu, current_user)->
      @activeTab = optionMenu
      @eventable_id = current_user
      @layoutEvents = new Main.EventsView
        option: @activeTab
      AlumNet.mainRegion.show(@layoutEvents)
      @showMenuUrl()

      self = @
      @layoutEvents.on "navigate:menu:events", (valueClick, current_user)->
        self.eventable_id = current_user
        self.activeTab = valueClick
        self.showMenuUrl()

      @layoutEvents.on 'events:search', (querySearch, collection)->
        collection.search(querySearch)

    showDiscoverEvents: ()->
      AlumNet.navigate("events/discover")
      events = AlumNet.request("results:events")
      @results = events

      eventsView = new AlumNet.EventsApp.Discover.EventsView
        collection: events
        parentView: @layoutEvents

      @layoutEvents.events_region.show(eventsView)
      @showFilters()

    showMyEvents: (eveactiveTabntable_id)->
      AlumNet.navigate("events/manage")
      events = new AlumNet.Entities.EventsCollection null,
        eventable: 'users'
        eventable_id: @eventable_id
      events.page = 1
      events.fetch
        data: { page: events.page, per_page: events.rows }
        reset: true

      eventsView = new AlumNet.EventsApp.Manage.EventsView
        collection: events

      @layoutEvents.events_region.show(eventsView)

      self = @
      eventsView.on "events:reload", ->
        that = @
        newCollection = new AlumNet.Entities.EventsCollection null,
          eventable: 'users'
          eventable_id: self.eventable_id
        query = _.extend({ page: ++@collection.page, per_page: @collection.rows })
        newCollection.fetch
          data: query
          reset: true
          success: (collection)->
            that.collection.add(collection.models)
            if collection.length < collection.rows
              that.endPagination()

    showFilters: ()->
      filters = new AlumNet.Shared.Views.Filters.Events.General
        results_collection: @results
      @layoutEvents.filters_region.show(filters)

    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "discoverEvents"
          self.showDiscoverEvents()
        when "myEvents"
          self.showMyEvents(self.eventable_id)
