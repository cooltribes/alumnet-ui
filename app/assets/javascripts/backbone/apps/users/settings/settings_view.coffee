@AlumNet.module 'UsersApp.Settings', (Settings, @AlumNet, Backbone, Marionette, $, _) ->
  class Settings.Layout extends Marionette.LayoutView
    template: 'users/settings/templates/layout'

    regions:
      main_region: "#region_main"
      content_region: "#region_content"

    events:
      'click .optionMenu': 'goOptionMenu'

    initialize: (options)->
      @opcionInteger(options.option)
      @tab = @opcionInteger(options.option)
      @class = [
        "", "", ""
      ]
      @class[parseInt(@tab)] = "--active"

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "manageNotifications"
          return 0
     
    templateHelpers: ->
      classOf: (step) =>
        @class[step]

    goOptionMenu: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      @valueClick = click.attr("data-menu")
      @trigger "navigate:menu", @valueClick
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenu").removeClass("submenuSettings__item__link--active")
      element.addClass("submenuSettings__item__link--active")
