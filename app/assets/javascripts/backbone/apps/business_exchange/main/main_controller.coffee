@AlumNet.module 'BusinessExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    businessProfiles: null
    businessTasks: null
    activeTab: "businessProfiles"

    showMainBusinessExchange: (optionMenu)->
      @activeTab = optionMenu
      current_user = AlumNet.current_user
      
      # Check cookies for first visit
      if not Cookies.get('business_exchange_visit')
        modal = new Main.ModalBusiness
        $('#container-modal-business').html(modal.render().el)
        Cookies.set('business_exchange_visit', 'true')

      @layoutBusiness = new Main.BusinessExchange
        option: @activeTab
        current_user: current_user
      AlumNet.mainRegion.show(@layoutBusiness)
      @showMenuUrl()
      self = @

      @layoutBusiness.on "navigate:menu:programs", (valueClick)-> 
        self.activeTab = valueClick
        self.showMenuUrl()

      @layoutBusiness.on 'business:search', (querySearch)->
        self.querySearch = querySearch
        if self.activeTab == "businessProfiles"
          self.businessProfiles.fetch
            url: AlumNet.api_endpoint + "/business"
            data: querySearch  
        else if self.activeTab == "yourTasks"
          self.businessTasks.fetch
            data: querySearch
  
    showBusinessProfile: ()->
      AlumNet.navigate("business-exchange/profiles")
      @businessProfiles = new AlumNet.Entities.BusinessCollection
      @businessProfiles.fetch
        url: AlumNet.api_endpoint + "/business"        
        data: 
          limit: 9      

      view = new AlumNet.BusinessExchangeApp.Profile.BusinessProfiles
        collection: @businessProfiles

      @layoutBusiness.cards_region.show(view)

    showYourTasks: ->
      AlumNet.navigate("business-exchange/tasks")
      @businessTasks = new AlumNet.Entities.BusinessExchangeCollection
      @businessTasks.fetch
        data: 
          limit: 9      

      view = new AlumNet.BusinessExchangeApp.Home.Tasks
        collection: @businessTasks

      @layoutBusiness.cards_region.show(view) 

    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "businessProfiles"
          self.showBusinessProfile()
        when "yourTasks"
          self.showYourTasks()

