@AlumNet.module 'HeaderApp.Menu', (Menu, @AlumNet, Backbone, Marionette, $, _) ->
  class Menu.MessageViewEmpty extends Marionette.ItemView
    template: 'header/menu/templates/messageEmpty'
    className: 'notification__empty'

  class Menu.MessageView extends Marionette.ItemView
    tagName: 'li'
    role: 'presentation'
    className: 'navTopBar__notification'
    template: 'header/menu/templates/message'

  class Menu.MessagesView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'navTopBar__dropdownMenu'
    childView: Menu.MessageView
    emptyView: Menu.MessageViewEmpty

  class Menu.NotificationViewEmpty extends Marionette.ItemView
    template: 'header/menu/templates/notificationEmpty'
    className: 'notification__empty'

  class Menu.NotificationView extends Marionette.ItemView
    tagName: 'li'
    role: 'presentation'
    className: 'navTopBar__notification'
    template: 'header/menu/templates/notification'

  class Menu.NotificationsView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'navTopBar__dropdownMenu'
    childView: Menu.NotificationView
    emptyView: Menu.NotificationViewEmpty

  class Menu.MenuBar extends Marionette.LayoutView

    initialize: ->
      @points = @model.profile.get("points")
      @listenTo(@model, 'change:unread_messages_count', @updateMessagesCountBadge)
      @listenTo(@model, 'change:unread_notifications_count', @updateNotificationsCountBadge)
      @listenTo(@model, 'change:unread_friendshipNotifications_count', @updateFriendshipNotificationsCountBadge)
      @listenTo(@model, 'change:avatar', @changeAvatar)
      @listenTo(@model, 'change:member', @changeMembresia)
      @listenTo(@model, 'render:points', @changePoints)

      # @model.on('change:unread_messages_count', @updateMessagesCountBadge, @)
      # @model.on('change:unread_notifications_count', @updateNotificationsCountBadge, @)


    getTemplate: ->
      if @model.isActive()
        'header/menu/templates/regular_layout'
      else
        'header/menu/templates/registration_layout'

    className: 'ng-scope'
    regions:
      messagesBox: '#js-menu-messages-box'
      notificationsBox: '#js-menu-notifications-box'
      friendshipNotificationsBox: '#js-menu-friendship-notifications-box'

    events:
      'click #js-menu-messages': 'menuMessageClicked'
      'click #js-menu-notifications': 'menuNotificationClicked'
      'click @ui.changeHeader': 'changeHeader'
      'click @ui.notificationsMarkAll': 'markAllNotifications'
      'click @ui.requestsMarkAll': 'markAllRequests'
      'click .navTopBar__left__item' : 'menuOptionClicked'
      'click #programsList li' : 'dropdownClicked'
      'click #accountList li' : 'accountDropdownClicked'

    ui:
      'messagesBadge': '#js-messages-badge'
      'notificationsBadge': '#js-notifications-badge'
      'friendshipNotificationsBadge': '#js-friendship-notifications-badge'
      'changeHeader': '#js-changeHeader'
      'notificationsMarkAll': '#js-notifications-mark-all'
      'requestsMarkAll': '#js-friendship-notifications-mark-all'
      'avatarImg': '#header-avatar'

    changePoints: ->
      $(".totalPoints").text(@model.profile.get("points"))

    changeMembresia: ->
      @render()

    changeAvatar: ->
      view = @
      @model.fetch
        success: (model)->
          avatar = "#{model.get('avatar').medium}?#{new Date().getTime()}"
          view.ui.avatarImg.attr('src', avatar)

    markAllNotifications: (e)->
      e.preventDefault()
      AlumNet.current_user.notifications.markAllAsRead()
      view = @
      @model.fetch
        success: ->
          view.updateNotificationsCountBadge()

    markAllRequests: (e)->
      e.preventDefault()
      AlumNet.current_user.friendship_notifications.markAllAsRead()
      view = @
      @model.fetch
        success: ->
          view.updateFriendshipNotificationsCountBadge()

    templateHelpers: ->
      model = @model
      #console.log @model
      first_name: @model.profile.get("first_name")
      isAdmin: @model.isAdmin()
      points: @points
      daysLeft: model.get('days_membership')
      memberTitle: ->
        if(model.get('member')==1)
          return "Active member"
        if(model.get('member')==2)
          return "Expiring membership"
        if(model.get('member')==3)
          return "Lifetime member"
        return "Not a member"


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

    updateFriendshipNotificationsCountBadge: ->
      value = @model.get('unread_friendship_notifications_count')
      @ui.friendshipNotificationsBadge.html(value)
      if value > 0
        @ui.friendshipNotificationsBadge.show()
      else
        @ui.friendshipNotificationsBadge.hide()

    menuMessageClicked: (e)->
      @model.set("unread_messages_count", 0)

    menuNotificationClicked: (e)->
      AlumNet.current_user.notifications.markAllAsRead()
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

      if @model.get("unread_friendship_notifications_count") > 0
        @ui.friendshipNotificationsBadge.show()
      else
        @ui.friendshipNotificationsBadge.hide()

    changeHeader: (e)->
      # e.preventDefault()
      # alert "Changing header to regular user"
      AlumNet.execute('header:show:admin')

    menuOptionClicked: (e)->
      $('.navTopBar__left__item').removeClass "navTopBar__left__item--active"
      if $(e.target).is('i') || $(e.target).is('span')
        if ! $(e.target).parent().hasClass 'dropdown-toggle'
          $(e.target).parent().addClass "navTopBar__left__item--active"
      else
        if ! $(e.target).hasClass 'dropdown-toggle'
          $(e.target).addClass "navTopBar__left__item--active"


    dropdownClicked: (e)->
      $('#programsLayoutOption').addClass "navTopBar__left__item--active"

    accountDropdownClicked: (e)->
      $('.navTopBar__left__item').removeClass "navTopBar__left__item--active"

  class Menu.AdminBar extends Marionette.LayoutView
    template: 'header/menu/templates/admin_layout'

    className: 'ng-scope'

    ui:
      'changeHeader': '#js-changeHeader'

    events:
      'click @ui.changeHeader': 'changeHeader'
      'click .navTopBarAdmin__left__item' : 'menuOptionClicked'

    onShow: ->
      $('.navTopBarAdmin__left__list li:first-child a.navTopBarAdmin__left__item').addClass "navTopBarAdmin__left__item--active"

    menuOptionClicked: (e)->
      $('.navTopBarAdmin__left__item').removeClass "navTopBarAdmin__left__item--active"
      if $(e.target).is('i') || $(e.target).is('span')
        if ! $(e.target).parent().hasClass 'dropdown-toggle'
          $(e.target).parent().addClass "navTopBarAdmin__left__item--active"
      else
        if ! $(e.target).hasClass 'dropdown-toggle'
          $(e.target).addClass "navTopBarAdmin__left__item--active"

    templateHelpers: ->
      first_name: @model.profile.get("first_name")
      isAlumnetAdmin: @model.isAlumnetAdmin()

    changeHeader: (e)->
      # e.preventDefault()
      AlumNet.execute('header:show:regular')

  class Menu.ExternalBar extends Marionette.LayoutView
    template: 'header/menu/templates/external_layout'

    className: 'ng-scope'

    events:
      'click .navTopBarAdmin__left__item' : 'menuOptionClicked'

    onShow: ->
      $('.navTopBarAdmin__left__list li:first-child a.navTopBarAdmin__left__item').addClass "navTopBarAdmin__left__item--active"

    menuOptionClicked: (e)->
      $('.navTopBarAdmin__left__item').removeClass "navTopBarAdmin__left__item--active"
      if $(e.target).is('i') || $(e.target).is('span')
        if ! $(e.target).parent().hasClass 'dropdown-toggle'
          $(e.target).parent().addClass "navTopBarAdmin__left__item--active"
      else
        if ! $(e.target).hasClass 'dropdown-toggle'
          $(e.target).addClass "navTopBarAdmin__left__item--active"

    templateHelpers: ->
      first_name: @model.profile.get("first_name")
      isAlumnetAdmin: @model.isAlumnetAdmin()


  class Menu.OnboardingBar extends Marionette.LayoutView
    template: 'header/menu/templates/onboarding_layout'

    className: 'ng-scope'
