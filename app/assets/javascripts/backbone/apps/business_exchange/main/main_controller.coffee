@AlumNet.module 'BusinessExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    showMainBusinessExchange: (optionMenu)->
      @layoutBusiness = new Main.BusinessExchange
        option: optionMenu
      AlumNet.mainRegion.show(@layoutBusiness)
      @showMenuUrl(optionMenu)
      self = @
      @layoutBusiness.on "navigate:menu:programs", (valueClick)-> 
        self.showMenuUrl(valueClick)
        console.log valueClick

    showBusinessProfile: ()->
      AlumNet.navigate("business-exchange/profiles")
      business = new AlumNet.Entities.BusinessCollection
      business.fetch
        url: AlumNet.api_endpoint + "/business"        
        data: 
          limit: 3      

      view = new AlumNet.BusinessExchangeApp.Profile.BusinessProfiles
        collection: business

      @layoutBusiness.cards_region.show(view) 

    showYourTasks: ->
      AlumNet.navigate("business-exchange/your-tasks")
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/business_exchanges/my'
      myTasksView = new AlumNet.BusinessExchangeApp.YourTasks.List
        collection: tasks

      @layoutBusiness.cards_region.show(myTasksView)

    showMenuUrl: (optionMenu)->
      self = @
      switch optionMenu
        when "businessProfiles"
          self.showBusinessProfile()
        when "yourTasks"
          self.showYourTasks()
      