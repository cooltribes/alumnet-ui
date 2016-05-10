@AlumNet.module 'BusinessExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    businessProfilesCollection: null
    businessTasksCollection: null
    activeTab: "businessProfiles"

    showMainLayout: (optionMenu)->
      @activeTab = optionMenu
      current_user = AlumNet.current_user

      @layoutBusiness = new Main.BusinessExchange
        option: @activeTab
        current_user: current_user
      AlumNet.mainRegion.show(@layoutBusiness)
      @showRegionMenu()
      @showAutomaches()

      # Check cookies for first visit
      if not Cookies.get('business_exchange_visit')
        modal = new Main.ModalBusiness
        $('#container-modal-business').html(modal.render().el)
        Cookies.set('business_exchange_visit', 'true')

      self = @
      @layoutBusiness.on "navigate:menu:left", (valueClick)->
        self.activeTab = valueClick
        self.showRegionMenu()

      @layoutBusiness.on "navigate:menu:right", (valueClick)->
        switch valueClick
          when "automatches"
            self.showAutomaches()

      @layoutBusiness.on 'business:search', (querySearch)->
        querySearch.per_page = 8
        view = self.layoutBusiness.cards_region.currentView
        view.query = querySearch

        view.collection.fetch
          reset: true
          remove: true
          data: querySearch

    showBusinessProfile: ()->
      controller = @
      AlumNet.navigate("business-exchange/profiles")
      @businessProfilesCollection = new AlumNet.Entities.BusinessCollection
      @businessProfilesCollection.url = AlumNet.api_endpoint + "/business"
      query = { per_page: 8 }

      view = new AlumNet.BusinessExchangeApp.Profile.BusinessProfiles
        collection: @businessProfilesCollection
        query: query

      @layoutBusiness.cards_region.show(view)

      self = @
      view.on "add:child", (viewInstance)->
        self.applyMasonry(viewInstance)

    showTasks: ->
      AlumNet.navigate("business-exchange/tasks")
      @businessTasksCollection = new AlumNet.Entities.BusinessExchangeCollection
      query = { per_page: 8 }

      view = new AlumNet.BusinessExchangeApp.Home.Tasks
        collection: @businessTasksCollection
        query: query

      @layoutBusiness.cards_region.show(view)

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

    showRegionMenu: ->
      self = @
      switch @activeTab
        when "businessProfiles"
          self.showBusinessProfile()
        when "yourTasks"
          self.showTasks()

