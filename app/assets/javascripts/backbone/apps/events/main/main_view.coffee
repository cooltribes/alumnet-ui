@AlumNet.module 'EventsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.EventsView extends Marionette.LayoutView
    template: 'events/main/templates/layout'

    regions:
      meetups_region: '#meetups-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .js-search': 'search'

    initialize: (options)->
      @opcionInteger(options.option)
      @tab = @opcionInteger(options.option)
      @class = [
        "", "", ""
      ]
      @class[parseInt(@tab)] = "--active"

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "discoverEvents"
          return 0
        when "myEvents"
          return 1

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      @valueClick = click.attr("data-menu")
      @optionMain = @valueClick
      @trigger "navigate:menu:events",@valueClick, AlumNet.current_user.id
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")
