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
      'click #alumniList li' : 'dropdownClickedAlumni'
      'click #groupsList li' : 'dropdownClickedGroups'
      'click #eventsList li' : 'dropdownClickedEvents'
      'click #programsList li' : 'dropdownClicked'
      'click #companiesList li' : 'dropdownClickedCompanies'
      'click #accountList li' : 'accountDropdownClicked'
      'click @ui.searchBtn' : 'clickSearchBtn'
      'keypress @ui.searchInput' : 'keypressSearch'
      'focus @ui.searchInput' : 'focusSearchBar'
      'blur @ui.searchInput' : 'blurSearchBar'

    ui:
      'messagesBadge': '#js-messages-badge'
      'notificationsBadge': '#js-notifications-badge'
      'friendshipNotificationsBadge': '#js-friendship-notifications-badge'
      'changeHeader': '#js-changeHeader'
      'notificationsMarkAll': '#js-notifications-mark-all'
      'requestsMarkAll': '#js-friendship-notifications-mark-all'
      'avatarImg': '#header-avatar'
      'searchInput': '#js-search-input'
      'searchBar': '.js-searchBar'
      'searchBtn': '.js-globalsearch-btn'

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
      @ui.notificationsBadge.hide()
      AlumNet.current_user.notifications.markAllAsRead()
      view = @
      @model.fetch
        success: ->
          title = document.title.split('-')
          AlumNet.setTitle(title[1])
          #view.updateNotificationsCountBadge()

    markAllRequests: (e)->
      e.preventDefault()
      @ui.friendshipNotificationsBadge.hide()
      AlumNet.current_user.friendship_notifications.markAllAsRead()
      view = @
      @model.fetch
        success: ->
          title = document.title.split('-')
          AlumNet.setTitle(title[1])
          #view.updateFriendshipNotificationsCountBadge()

    templateHelpers: ->
      model = @model
      environment = AlumNet.environment
      environment: AlumNet.environment
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

    focusSearchBar: (e)->
      input = e.currentTarget
      $(input).closest(".js-searchBar").addClass("wideBar")


    blurSearchBar: (e)->
      input = e.currentTarget
      $(input).closest(".js-searchBar").removeClass("wideBar")

    keypressSearch: (e)->
      if e.keyCode == 13
        input = $(e.currentTarget)
        input.blur()
        #capture the value of the current target
        search_term = input.val().trim()
        @searchInAlumNet(search_term)

    clickSearchBtn: (e)->
      btn = e.currentTarget
      search_term = @ui.searchInput.val().trim()
      @searchInAlumNet(search_term)


    updateMessagesCountBadge: ->
      view = @
      @model.fetch
        success: (model)->
          value = model.get('unread_messages_count')
          view.ui.messagesBadge.html(value)
          if value > 0
            view.ui.messagesBadge.show()
          else
            view.ui.messagesBadge.hide()

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
      view = @
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

    onShow: ->
      view = @
      @ui.searchInput.autocomplete
        source: AlumNet.api_endpoint + "/suggestions"
        minLength: 2
        select: (event, ui)->
          $(@).val(ui.item.name)
          false

      @ui.searchInput.autocomplete("instance")._renderItem = (ul, item)->
        link = view.autocompleteLink(item)
        $("<li>").data("item.autocomplete", item)
        .append(link)
        .appendTo(ul)

    searchInAlumNet: (search_term)->
      if search_term != ""
        AlumNet.execute("search:show:results", search_term)

    autocompleteLink: (item)->
      if item.type == "profile"
        url = "#users/#{item.id}/posts"
      else
        url = "##{item.type}s/#{item.id}/posts"
      #TEMPORAL MIENTRAS SE DECIDE QUE IMAGEN PONER POR DEFECTO
      if item.image
        "<img src='#{item.image}'> - <a href='#{url}'>#{item.name}</a> - #{item.type}"
      else
        "<a href='#{url}'>#{item.name}</a> - #{item.type}"

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

    dropdownClickedAlumni: (e)->
      $('.navTopBar__left__item').removeClass "navTopBar__left__item--active"
      $('#alumniLayoutOption').addClass "navTopBar__left__item--active"

    dropdownClickedGroups: (e)->
      $('.navTopBar__left__item').removeClass "navTopBar__left__item--active"
      $('#groupsLayoutOption').addClass "navTopBar__left__item--active"

    dropdownClickedEvents: (e)->
      $('.navTopBar__left__item').removeClass "navTopBar__left__item--active"
      $('#eventsLayoutOption').addClass "navTopBar__left__item--active"

    dropdownClicked: (e)->
      $('.navTopBar__left__item').removeClass "navTopBar__left__item--active"
      $('#programsLayoutOption').addClass "navTopBar__left__item--active"

    dropdownClickedCompanies: (e)->
      $('.navTopBar__left__item').removeClass "navTopBar__left__item--active"
      $('#companiesLayoutOption').addClass "navTopBar__left__item--active"

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
