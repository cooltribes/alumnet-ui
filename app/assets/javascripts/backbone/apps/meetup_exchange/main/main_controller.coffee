@AlumNet.module 'MeetupExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverMeetups"
    discoverCollection: null
    myApplications: null
    manageMeetups: null

    showMainMeetupExchange: (optionMenu)->
      @activeTab = optionMenu
      @layoutMeetupExchange = new Main.MeetupExchange
        option: @activeTab
      AlumNet.mainRegion.show(@layoutMeetupExchange)
      @showMenuUrl()
      @showAutomatches()

      # Check cookies for first visit
      if not Cookies.get('meetup_exchange_visit')
        modal = new Main.ModalMeetups
        $('#container-modal-meetup').html(modal.render().el)
        Cookies.set('meetup_exchange_visit', 'true')

      self = @
      @layoutMeetupExchange.on "navigate:menu:meetup", (valueClick)->
        self.activeTab = valueClick
        self.showMenuUrl()

      @layoutMeetupExchange.on "navigate:menuRight", (valueClick)->
        switch valueClick
          when "automatches"
            self.showAutomatches()

      @layoutMeetupExchange.on 'meetups:search', (querySearch)->
        self.querySearch = querySearch
        if self.activeTab == "discoverMeetups"
          self.discoverCollection.fetch
            data: querySearch  
        else if self.activeTab == "myApplications"
          self.myApplications.fetch
            data: querySearch
            url: AlumNet.api_endpoint + '/meetup_exchanges/applied'

        else if self.activeTab == "manageMeetups"
          self.manageMeetups.fetch
            data: querySearch 
            url: AlumNet.api_endpoint + '/meetup_exchanges/my'

    showDiscoverMeetup: ()->
      AlumNet.navigate("meetup-exchange/discover")
      @discoverCollection = new AlumNet.Entities.MeetupExchangeCollection
      @discoverCollection.fetch()
      discoverView = new AlumNet.MeetupExchangeApp.Discover.List
        collection: @discoverCollection

      @layoutMeetupExchange.meetup_region.show(discoverView)

    showMyApplications: ()->
      AlumNet.navigate("meetup-exchange/applied")
      @myApplications = new AlumNet.Entities.MeetupExchangeCollection
      @myApplications.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/applied'
      appliedView = new AlumNet.MeetupExchangeApp.Applied.List
        collection: @myApplications

      @layoutMeetupExchange.meetup_region.show(appliedView)

    showManageMeetups: ()->
      AlumNet.navigate("meetup-exchange/your-tasks")
      @manageMeetups = new AlumNet.Entities.MeetupExchangeCollection
      @manageMeetups.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/my'
      myTasksView = new AlumNet.MeetupExchangeApp.YourTasks.List
        collection: @manageMeetups

      @layoutMeetupExchange.meetup_region.show(myTasksView)

    showAutomatches: ()->
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch()
        #url: AlumNet.api_endpoint + '/meetup_exchanges/automatches'
      automatchesView = new AlumNet.MeetupExchangeApp.AutoMatches.List
        collection: tasks

      @layoutMeetupExchange.suggestions_regions.show(automatchesView)

    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "discoverMeetups"
          self.showDiscoverMeetup()
        when "myApplications"
          self.showMyApplications()
        when "manageMeetups"
          self.showManageMeetups()
    
