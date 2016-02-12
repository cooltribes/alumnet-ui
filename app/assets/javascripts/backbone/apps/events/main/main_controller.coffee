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
      @layoutEvents.on "navigate:menu:events", (valueClick)->
        self.activeTab = valueClick
        self.showMenuUrl()

    showDiscoverEvents: ()->
      events = new AlumNet.Entities.EventsCollection
      events.fetch()
      eventsView = new AlumNet.EventsApp.Discover.EventsView
        collection: events

      @layoutEvents.meetups_region.show(eventsView)

    showMyEvents: (eventable_id)->
      events = new AlumNet.Entities.EventsCollection null,
        eventable: 'users'
        eventable_id: @eventable_id
      events.fetch()
      eventsView = new AlumNet.EventsApp.Manage.EventsView
        collection: events

      @layoutEvents.meetups_region.show(eventsView)

    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "discoverEvents"
          self.showDiscoverEvents()
        when "myEvents"
          self.showMyEvents(@eventable_id)

     