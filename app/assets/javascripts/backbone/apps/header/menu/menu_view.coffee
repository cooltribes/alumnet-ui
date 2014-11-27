@AlumNet.module 'HeaderApp.Menu', (Menu, @AlumNet, Backbone, Marionette, $, _) ->

  class Menu.MessageView extends Marionette.ItemView
    tagName: 'li'
    role: 'presentation'
    className: 'navTopBar__notification'
    template: 'header/menu/templates/message'

  class Menu.MessagesView extends Marionette.CollectionView
    tagName: 'ul'
    childView: Menu.MessageView


  class Menu.MenuBar extends Marionette.LayoutView
    className: 'ng-scope'
    template: 'header/menu/templates/header_layout'
    regions:
      messagesBox: '#js-menu-messages-box'
    templateHelpers: ->
      first_name: @model.profile.get("first_name")