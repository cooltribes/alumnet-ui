@AlumNet.module 'HeaderApp.Menu', (Menu, @AlumNet, Backbone, Marionette, $, _) ->

  class Menu.MenuBar extends Marionette.CompositeView
    className: 'ng-scope'
    template: 'header/menu/templates/header_container'
    templateHelpers: ->
      first_name: @model.profile.get("first_name")
