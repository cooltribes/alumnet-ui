@AlumNet.module 'EventsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.EventsView extends Marionette.LayoutView
    template: 'events/main/templates/layout'

    regions:
      events_region: '#events-region'
      filters_region: '#filters-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .js-search': 'performSearch'

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
      @trigger "navigate:menu:events", @valueClick, AlumNet.current_user.id
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger 'events:search', data.search_term, @events_region.currentView.collection