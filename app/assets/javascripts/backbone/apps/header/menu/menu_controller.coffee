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
          data: { page: 1, per_page: 6 }
        current_user.friendship_notifications.fetch
          data: { page: 1, per_page: 6 }
        messagesList = new Menu.MessagesView
          collection: current_user.messages
        notificationsList = new Menu.NotificationsView
          collection: current_user.notifications
        friendshipNotificationsList = new Menu.NotificationsView
          collection: current_user.friendship_notifications

        AlumNet.headerRegion.show(menuLayout)
        menuLayout.messagesBox.show(messagesList)
        menuLayout.notificationsBox.show(notificationsList)
        menuLayout.friendshipNotificationsBox.show(friendshipNotificationsList)
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

    showExternal: ->

      if AlumNet.headerRegion.currentView instanceof Menu.ExternalBar
        return

      current_user = AlumNet.current_user
      AlumNet.headerRegion.reset()
      if current_user.isExternal() && current_user.isActive()
        menuLayout = new Menu.ExternalBar
          model: current_user
        AlumNet.headerRegion.show(menuLayout)

    showOnboarding: ->

      if AlumNet.headerRegion.currentView instanceof Menu.ExternalBar
        return

      current_user = AlumNet.current_user
      AlumNet.headerRegion.reset()
      menuLayout = new Menu.OnboardingBar
        model: current_user
      AlumNet.headerRegion.show(menuLayout)




