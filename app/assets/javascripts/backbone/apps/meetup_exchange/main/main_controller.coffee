@AlumNet.module 'MeetupExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverMeetups"
    discoverCollection: null
    myApplications: null
    manageMeetups: null

    showMainLayout: (optionMenu)->
      @activeTab = optionMenu
      @layoutMeetupExchange = new Main.MeetupExchange
        option: @activeTab
      AlumNet.mainRegion.show(@layoutMeetupExchange)
      @showRegionMenu()
      @showAutomatches()

      # Check cookies for first visit
      if not Cookies.get('meetup_exchange_visit')
        modal = new Main.ModalMeetups
        $('#container-modal-meetup').html(modal.render().el)
        Cookies.set('meetup_exchange_visit', 'true')

      self = @
      @layoutMeetupExchange.on "navigate:menu:left", (valueClick)->
        self.activeTab = valueClick
        self.showRegionMenu()

      @layoutMeetupExchange.on "navigate:menu:right", (valueClick)->
        switch valueClick
          when "automatches"
            self.showAutomatches()

      @layoutMeetupExchange.on 'meetups:search', (querySearch)->
        querySearch.per_page = 8
        view = self.layoutMeetupExchange.meetup_region.currentView
        view.query = querySearch

        view.collection.fetch
          reset: true
          remove: true
          data: querySearch

    showDiscoverMeetup: ()->
      AlumNet.navigate("meetup-exchange/discover")
      @discoverCollection = new AlumNet.Entities.MeetupExchangeCollection
      query =  query = { per_page: 8 }

      discoverView = new AlumNet.MeetupExchangeApp.Discover.List
        collection: @discoverCollection
        query: query

      @layoutMeetupExchange.meetup_region.show(discoverView)

    showMyApplications: ()->
      AlumNet.navigate("meetup-exchange/applied")
      @myApplications = new AlumNet.Entities.MeetupExchangeCollection
      @myApplications.url = AlumNet.api_endpoint + '/meetup_exchanges/applied'
      query =  query = { per_page: 8 }

      appliedView = new AlumNet.MeetupExchangeApp.Applied.List
        collection: @myApplications
        query: query

      @layoutMeetupExchange.meetup_region.show(appliedView)

    showManageMeetups: ()->
      AlumNet.navigate("meetup-exchange/your-tasks")
      @manageMeetups = new AlumNet.Entities.MeetupExchangeCollection
      @manageMeetups.url = AlumNet.api_endpoint + '/meetup_exchanges/my'
      query =  query = { per_page: 8 }

      myTasksView = new AlumNet.MeetupExchangeApp.YourTasks.List
        collection: @manageMeetups
        query: query

      @layoutMeetupExchange.meetup_region.show(myTasksView)

    showAutomatches: ()->
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/automatches'
      automatchesView = new AlumNet.MeetupExchangeApp.AutoMatches.List
        collection: tasks

      @layoutMeetupExchange.suggestions_regions.show(automatchesView)

    showRegionMenu: ()->
      self = @
      switch @activeTab
        when "discoverMeetups"
          self.showDiscoverMeetup()
        when "myApplications"
          self.showMyApplications()
        when "manageMeetups"
          self.showManageMeetups()

