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


  class Menu.MenuBar extends Marionette.LayoutView
    initialize: ->
      @model.on('change:unread_messages_count', @updateCountBadge, @)

    getTemplate: ->
      if @model.isActive()
        if @model.isAlumnetAdmin()
          'header/menu/templates/admin_layout'
        else
          'header/menu/templates/regular_layout'
      else
        'header/menu/templates/registration_layout'

    className: 'ng-scope'
    # template: 'header/menu/templates/header_layout'
    regions:
      messagesBox: '#js-menu-messages-box'
    events:
      'click #js-menu-messages': 'menuMessageClicked'
    ui:
      'messagesBadge': '#js-messages-badge'

    templateHelpers: ->
      first_name: @model.profile.get("first_name")

    updateCountBadge: ->
      value = @model.get('unread_messages_count')
      @ui.messagesBadge.html(value)
      if value > 0
        @ui.messagesBadge.show()
      else
        @ui.messagesBadge.hide()

    menuMessageClicked: (e)->
      @model.set("unread_messages_count", 0)

    onRender: ->
      if @model.get("unread_messages_count") > 0
        @ui.messagesBadge.show()
      else
        @ui.messagesBadge.hide()

