@AlumNet.module 'MeetupExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverJobExchange"
    discoverCollection: null
    myApplications: null
    manageJobs: null

    showMainMeetupExchange: (optionMenu)->
      @activeTab = optionMenu
      @layoutJobExchange = new Main.MeetupExchange
        option: @activeTab
      AlumNet.mainRegion.show(@layoutJobExchange)
      @showMenuUrl()
