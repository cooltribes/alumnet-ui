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
      AlumNet.navigate("events/discover")
      events = new AlumNet.Entities.EventsCollection
      events.page = 1
      events.fetch
        page: events.page
        per_page: events.rows
      eventsView = new AlumNet.EventsApp.Discover.EventsView
        collection: events

      @layoutEvents.meetups_region.show(eventsView)

      events.on "events:reload", ->
        newCollection = new AlumNet.Entities.EventsCollection
        query = _.extend(querySearch, { page: ++@collection.page, per_page: @collection.rows })
        newCollection.fetch
          data: query
          success: (collection)->
            that.collection.add(collection.models)
            if collection.length < collection.rows
              that.endPagination()

      events.on "add:child", (viewInstance)->
        container = $('.main-events-area')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-6'
        container.append( $(viewInstance.el) ).masonry 'reloadItems'
      events

    showMyEvents: (eventable_id)->
      AlumNet.navigate("events/manage")
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

     