@AlumNet.module 'JobExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverJobExchange"
    discoverCollection: null
    myApplications: null
    manageJobs: null

    showMainJobExchange: (optionMenu)->
      @activeTab = optionMenu
      @layoutJobExchange = new Main.JobExchange
        option: @activeTab
      AlumNet.mainRegion.show(@layoutJobExchange)
      @showMenuUrl()

      # Check cookies for first visit
      if not Cookies.get('job_exchange_visit')
        modal = new Main.ModalJob
        $('#container-modal-job').html(modal.render().el)
        Cookies.set('job_exchange_visit', 'true')

      self = @
      @layoutJobExchange.on "navigate:menu:job", (valueClick)->
        self.activeTab = valueClick
        self.showMenuUrl()

      @layoutJobExchange.on 'jobs:search', (querySearch)->
        self.querySearch = querySearch

        if self.activeTab == "discoverJobExchange"
          self.discoverCollection.fetch
            data: querySearch  
        else if self.activeTab == "myApplications"
          self.myApplications.fetch
            data: querySearch 
        else if self.activeTab == "manageJobExchange"
          self.manageJobs.fetch
            data: querySearch 
        
    showDiscoverJobExchange: ->
      AlumNet.navigate("job-exchange/discover")
      @discoverCollection = new AlumNet.Entities.JobExchangeCollection
      @discoverCollection.page = 1
      @discoverCollection.url = AlumNet.api_endpoint + '/job_exchanges'
      @discoverCollection.fetch
        data: { page: @discoverCollection.page, per_page: @discoverCollection.rows }
        reset: true

      discoverView = new AlumNet.JobExchangeApp.Discover.List
        collection: @discoverCollection

      @layoutJobExchange.jobs_region.show(discoverView)

    showMyApplications: ->
      AlumNet.navigate("job-exchange/applied")
      @myApplications = new AlumNet.Entities.JobExchangeCollection
      @myApplications.page = 1
      @myApplications.url = AlumNet.api_endpoint + '/job_exchanges/applied?page='+@myApplications.page+'&per_page='+@myApplications.rows       
      @myApplications.fetch
        reset: true

      appliedJobsView = new AlumNet.JobExchangeApp.Applied.List
        collection: @myApplications

      @layoutJobExchange.jobs_region.show(appliedJobsView)

    showManageJobExchange: ->
      AlumNet.navigate("job-exchange/my-posts")
      @manageJobs = new AlumNet.Entities.JobExchangeCollection
      @manageJobs.page = 1
      @manageJobs.url = AlumNet.api_endpoint + '/job_exchanges/my?page='+@manageJobs.page+'&per_page='+@manageJobs.rows      
      @manageJobs.fetch
        reset: true

      myJobsView = new AlumNet.JobExchangeApp.MyJobs.List
        collection: @manageJobs

      @layoutJobExchange.jobs_region.show(myJobsView)

    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "discoverJobExchange"
          self.showDiscoverJobExchange()
        when "myApplications"
          self.showMyApplications()
        when "manageJobExchange"
          self.showManageJobExchange()
    
        