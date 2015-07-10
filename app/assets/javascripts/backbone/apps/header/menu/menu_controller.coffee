@AlumNet.module 'HeaderApp.Menu', (Menu, @AlumNet, Backbone, Marionette, $, _) ->
  class Menu.Controller
    show: ->

      if AlumNet.headerRegion.currentView instanceof Menu.MenuBar
        return

      current_user = AlumNet.current_user
      AlumNet.headerRegion.reset()
      menuLayout = new Menu.MenuBar
        model: current_user

      if current_user.isActive()
        current_user.messages.fetch()
        current_user.notifications.fetch
          data: { limit: 6 }
        messagesList = new Menu.MessagesView
          collection: current_user.messages
        notificationsList = new Menu.NotificationsView
          collection: current_user.notifications

        AlumNet.headerRegion.show(menuLayout)
        menuLayout.messagesBox.show(messagesList)
        menuLayout.notificationsBox.show(notificationsList)       
      else
        menuLayout = new Menu.MenuBar
          model: current_user

        AlumNet.headerRegion.show(menuLayout)

    showAdmin: ->     

      if AlumNet.headerRegion.currentView instanceof Menu.AdminBar
        return
        
      current_user = AlumNet.current_user
      AlumNet.headerRegion.reset()
      if current_user.isAdmin()
        menuLayout = new Menu.AdminBar
          model: current_user
        AlumNet.headerRegion.show(menuLayout)

  


