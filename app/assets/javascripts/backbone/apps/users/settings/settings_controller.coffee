@AlumNet.module 'UsersApp.Settings', (Settings, @AlumNet, Backbone, Marionette, $, _) ->
  class Settings.Controller

    showLayoutSettings: (id, optionSubMenu)->
      @optionSubMenu = optionSubMenu
      @layoutView = new Settings.Layout
        option: @optionSubMenu
      AlumNet.mainRegion.show(@layoutView)
      @showDetailBill()

      self = @ 
      @layoutView.on "navigate:menu", (option)->
        self.optionSubMenu = option
        self.showRegionMenu()

    showBilling: ->
      view = new AlumNet.UsersApp.Billing.Layout
      @layoutView.content_region.show(view)

    showManageNotifications: ->
     
      
    showPrivacy: ->
      #Fetch the collection
      privCollection = new AlumNet.Entities.PrivacyCollection
      privCollection.comparator = "id"
      privCollection.fetch
        success: (collection)->
          #Get the last one and insert one fake model for contact info
          # collection.at(collection.length - 1)
          collection.add
            description: "Who can see my contact information"
            value: -1

      privacyView = new AlumNet.UsersApp.Privacy.View
        collection: privCollection
      @layoutView.content_region.show(privacyView)

    showDetailBill: ->
      view = new AlumNet.UsersApp.Billing.DetailsBill
      @layoutView.content_region.show(view)

    showRegionMenu: ->
      self = @
      switch @optionSubMenu
        when "billing"
          self.showBilling()
        when "manageNotifications"
          self.showManageNotifications()
        when "privacy"
          self.showPrivacy()