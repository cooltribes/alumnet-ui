@AlumNet.module 'BusinessExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    showMainBusinessExchange: (optionMenu)->
      current_user = AlumNet.current_user
      @layoutBusiness = new Main.BusinessExchange
        option: optionMenu
        current_user: current_user
      AlumNet.mainRegion.show(@layoutBusiness)
      @showMenuUrl(optionMenu)
      self = @
      @layoutBusiness.on "navigate:menu:programs", (valueClick)-> 
        self.showMenuUrl(valueClick)

    showBusinessProfile: ()->
      AlumNet.navigate("business-exchange/profiles")
      business = new AlumNet.Entities.BusinessCollection
      business.fetch
        url: AlumNet.api_endpoint + "/business"        
        data: 
          limit: 9      

      view = new AlumNet.BusinessExchangeApp.Profile.BusinessProfiles
        collection: business

      @layoutBusiness.cards_region.show(view) 

    showYourTasks: ->
      AlumNet.navigate("business-exchange/tasks")
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch
        data: 
          limit: 9      

      view = new AlumNet.BusinessExchangeApp.Home.Tasks
        collection: tasks

      @layoutBusiness.cards_region.show(view) 

    showMenuUrl: (optionMenu)->
      self = @
      switch optionMenu
        when "businessProfiles"
          self.showBusinessProfile()
        when "yourTasks"
          self.showYourTasks()