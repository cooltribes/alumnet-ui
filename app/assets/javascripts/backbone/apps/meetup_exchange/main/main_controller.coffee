@AlumNet.module 'MeetupExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverMeetups"
    discoverCollection: null

    showMainMeetupExchange: (optionMenu)->
      @activeTab = optionMenu
      @layoutMeetupExchange = new Main.MeetupExchange
        option: @activeTab
      AlumNet.mainRegion.show(@layoutMeetupExchange)
      @showMenuUrl()

      # Check cookies for first visit
      if not Cookies.get('meetup_exchange_visit')
        modal = new Discover.ModalMeetups
        $('#container-modal-meetup').html(modal.render().el)
        Cookies.set('meetup_exchange_visit', 'true')

      self = @
      @layoutMeetupExchange.on "navigate:menu:meetup", (valueClick)->
        self.activeTab = valueClick
        self.showMenuUrl()

    showDiscoverMeetup: ()->
      AlumNet.navigate("meetup-exchange/discover")
      @discoverCollection = new AlumNet.Entities.MeetupExchangeCollection
      @discoverCollection.fetch()
      discoverView = new AlumNet.MeetupExchangeApp.Discover.List
        collection: @discoverCollection

      @layoutMeetupExchange.meetup_region.show(discoverView)

    showMyApplications: ()->
      AlumNet.navigate("meetup-exchange/applied")
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/applied'
      appliedView = new AlumNet.MeetupExchangeApp.Applied.List
        collection: tasks

      @layoutMeetupExchange.meetup_region.show(appliedView)

    showManageMeetups: ()->
      AlumNet.navigate("meetup-exchange/your-tasks")
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/my'
      myTasksView = new AlumNet.MeetupExchangeApp.YourTasks.List
        collection: tasks

      @layoutMeetupExchange.meetup_region.show(myTasksView)

    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "discoverMeetups"
          self.showDiscoverMeetup()
        when "myApplications"
          self.showMyApplications()
        when "manageMeetups"
          self.showManageMeetups()
    
