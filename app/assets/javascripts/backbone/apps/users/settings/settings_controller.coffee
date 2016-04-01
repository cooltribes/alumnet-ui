@AlumNet.module 'UsersApp.Settings', (Settings, @AlumNet, Backbone, Marionette, $, _) ->
  class Settings.Controller
    showLayoutSettings: (id, optionSubMenu)->
      @optionSubMenu = optionSubMenu
      @layoutView = new Settings.Layout
        option: @optionSubMenu
      AlumNet.mainRegion.show(@layoutView)

      self = @ 
      @layoutView.on "navigate:menu", (option)->
        self.optionSubMenu = option
        self.showRegionMenu()

    showBilling: ->
      view = new AlumNet.UsersApp.Billing.Layout
      @layoutView.content_region.show(view)

  # showManageNotifications: ->

    showRegionMenu: ->
      self = @
      switch @optionSubMenu
        when "billing"
          self.showBilling()
        # when "manageNotifications"
        #   self.showManageNotifications()
        #   
       