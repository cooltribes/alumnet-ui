@AlumNet.module 'HeaderApp.Menu', (Menu, @AlumNet, Backbone, Marionette, $, _) ->

  class Menu.MessageView extends Marionette.ItemView
    tagName: 'li'
    role: 'presentation'
    className: 'navTopBar__notification'
    template: 'header/menu/templates/message'

  class Menu.MessagesView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'navTopBar__dropdownMenu'
    childView: Menu.MessageView

  class Menu.NotificationView extends Marionette.ItemView
    tagName: 'li'
    role: 'presentation'
    className: 'navTopBar__notification'
    template: 'header/menu/templates/notification'

  class Menu.NotificationsView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'navTopBar__dropdownMenu'
    childView: Menu.NotificationView

  class Menu.MenuBar extends Marionette.LayoutView
    initialize: ->
      @model.on('change:unread_messages_count', @updateMessagesCountBadge, @)
      @model.on('change:unread_notifications_count', @updateNotificationsCountBadge, @)

    getTemplate: ->
      if @model.isActive()
        'header/menu/templates/regular_layout'
      else
        'header/menu/templates/registration_layout'

    className: 'ng-scope'
    regions:
      messagesBox: '#js-menu-messages-box'
      notificationsBox: '#js-menu-notifications-box'

    events:
      'click #js-menu-messages': 'menuMessageClicked'
      'click #js-menu-notifications': 'menuNotificationClicked'
      'click @ui.changeHeader': 'changeHeader'

    ui:
      'messagesBadge': '#js-messages-badge'
      'notificationsBadge': '#js-notifications-badge'
      'changeHeader': '#js-changeHeader'

    modelEvents:
      "change": "modelChange"

    modelChange: ->
      @render()  
    
    templateHelpers: ->
      first_name: @model.profile.get("first_name")
      isAlumnetAdmin: @model.isAlumnetAdmin()

    updateMessagesCountBadge: ->
      value = @model.get('unread_messages_count')
      @ui.messagesBadge.html(value)
      if value > 0
        @ui.messagesBadge.show()
      else
        @ui.messagesBadge.hide()

    updateNotificationsCountBadge: ->
      value = @model.get('unread_notifications_count')
      @ui.notificationsBadge.html(value)
      if value > 0
        @ui.notificationsBadge.show()
      else
        @ui.notificationsBadge.hide()

    menuMessageClicked: (e)->
      @model.set("unread_messages_count", 0)

    menuNotificationClicked: (e)->
      @model.set("unread_notifications_count", 0)

    onRender: ->
      if @model.get("unread_messages_count") > 0
        @ui.messagesBadge.show()
      else
        @ui.messagesBadge.hide()

      if @model.get("unread_notifications_count") > 0
        @ui.notificationsBadge.show()
      else
        @ui.notificationsBadge.hide()

    changeHeader: (e)->
      # e.preventDefault()
      # alert "Changing header to regular user"
      AlumNet.execute('header:show:admin')



  class Menu.AdminBar extends Marionette.LayoutView
    template: 'header/menu/templates/admin_layout'

    className: 'ng-scope'

    ui:
      'changeHeader': '#js-changeHeader'

    events:
      'click @ui.changeHeader': 'changeHeader'

    templateHelpers: ->
      first_name: @model.profile.get("first_name")
      isAlumnetAdmin: @model.isAlumnetAdmin()

    changeHeader: (e)->
      # e.preventDefault()

      AlumNet.execute('header:show:regular')