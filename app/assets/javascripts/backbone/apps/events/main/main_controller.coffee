@AlumNet.module 'EventsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "prueba"
    showMainEvents: (optionMenu)->
      @activeTab = optionMenu
      @layoutEvents = new Main.EventsView
        option: @activeTab
      AlumNet.mainRegion.show(@layoutEvents)
      @showDiscoverEvents()

    showDiscoverEvents: ()->
      events = new AlumNet.Entities.EventsCollection
      eventsView = new AlumNet.EventsApp.Discover.EventsView
        collection: events

      @layoutEvents.meetups_region.show(eventsView)


     