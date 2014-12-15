@AlumNet.module 'HeaderApp.Menu', (Menu, @AlumNet, Backbone, Marionette, $, _) ->
  class Menu.Controller
    show: ->
      current_user = AlumNet.current_user

      menuLayout = new Menu.MenuBar
        model: current_user

      if current_user.isActive()
        current_user.messages.fetch()
        messagesList = new Menu.MessagesView
          collection: current_user.messages

        AlumNet.headerRegion.show(menuLayout)
        menuLayout.messagesBox.show(messagesList)

      else
        menuLayout = new Menu.MenuBar
          model: current_user
        AlumNet.headerRegion.show(menuLayout)

