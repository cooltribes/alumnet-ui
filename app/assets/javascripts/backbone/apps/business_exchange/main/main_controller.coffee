@AlumNet.module 'BusinessExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    businessProfilesCollection: null
    businessTasksCollection: null
    activeTab: "businessProfiles"

    showMainBusinessExchange: (optionMenu)->
      @activeTab = optionMenu
      current_user = AlumNet.current_user
      
      @layoutBusiness = new Main.BusinessExchange
        option: @activeTab
        current_user: current_user
      AlumNet.mainRegion.show(@layoutBusiness)
      @showMenuUrl()
      @showAutomaches()

      # Check cookies for first visit
      if not Cookies.get('business_exchange_visit')
        modal = new Main.ModalBusiness
        $('#container-modal-business').html(modal.render().el)
        Cookies.set('business_exchange_visit', 'true')

      self = @
      @layoutBusiness.on "navigate:menu:programs", (valueClick)-> 
        self.activeTab = valueClick
        self.showMenuUrl()

      @layoutBusiness.on "navigate:menuRight", (valueClick)->
        switch valueClick
          when "automatches"
            self.showAutomaches()
          # when "filters"
          #   self.showFilters()

      @layoutBusiness.on 'business:search', (querySearch)->
        self.querySearch = querySearch
        if self.activeTab == "businessProfiles"
          self.businessProfilesCollection.fetch
            url: AlumNet.api_endpoint + "/business"
            data: querySearch  
        else if self.activeTab == "yourTasks"
          self.businessTasksCollection.fetch
            data: querySearch
  
    showBusinessProfile: ()->
      controller = @
      controller.querySearch = {}
      AlumNet.navigate("business-exchange/profiles")
      @businessProfilesCollection = new AlumNet.Entities.BusinessCollection
      @businessProfilesCollection.fetch
        url: AlumNet.api_endpoint + "/business"        
        data: 
          limit: 9      

      view = new AlumNet.BusinessExchangeApp.Profile.BusinessProfiles
        collection: @businessProfilesCollection

      @layoutBusiness.cards_region.show(view)

      self = @
      view.on "add:child", (viewInstance)->
        self.applyMasonry(viewInstance)

    showTasks: ->
      AlumNet.navigate("business-exchange/tasks")
      @businessTasksCollection = new AlumNet.Entities.BusinessExchangeCollection
      @businessTasksCollection.fetch
        data: 
          limit: 9      
      view = new AlumNet.BusinessExchangeApp.Home.Tasks
        collection: @businessTasksCollection

      @layoutBusiness.cards_region.show(view)

      self = @
      view.on "add:child", (viewInstance)->
        self.applyMasonry(viewInstance)

    showAutomaches: ->
      automachesCollection = new AlumNet.Entities.BusinessExchangeCollection
      automachesCollection.fetch
        url: AlumNet.api_endpoint + '/business_exchanges/automatches'   
    
      automatchesView = new  AlumNet.BusinessExchangeApp.AutoMatches.List
        collection: automachesCollection

      @layoutBusiness.filters_region.show(automatchesView)

    applyMasonry: (view)->
      container = $('.profiles-container')
      container.imagesLoaded ->
        container.masonry
          itemSelector: '.col-md-6'
      container.append( $(view.el) ).masonry 'reloadItems'

    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "businessProfiles"
          self.showBusinessProfile()
        when "yourTasks"
          self.showTasks()

