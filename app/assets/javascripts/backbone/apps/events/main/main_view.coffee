@AlumNet.module 'EventsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.EventsView extends Marionette.LayoutView
    template: 'events/main/templates/layout'

    regions:
      events_region: '#events-region'
      filters_region: '#filters-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .optionMenuRight' : 'goOptionMenuRight'
      'click .js-search': 'performSearch'

    initialize: (options)->
      @opcionInteger(options.option)
      @tab = @opcionInteger(options.option)
      @class = [
        "", "", ""
      ]
      @class[parseInt(@tab)] = "--active"

      if @tab == 0 
        $("#js-filters").show()
      else
        $("#js-filters").hide()

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "discoverEvents"
          return 0
        when "myEvents"
          return 1
        when "manageEvents"
          return 2

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      @valueClick = click.attr("data-menu")

      if @valueClick == 'discoverEvents'
        $("#js-filters").show()
      else
        $("#js-filters").hide()

      @trigger "navigate:menu:left", @valueClick, AlumNet.current_user.id
      @toggleLink(click)

    goOptionMenuRight: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @trigger "navigate:menu:right",valueClick
      @toggleLinkRight(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    toggleLinkRight: (element)->
      $(".optionMenuRight").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    getCurrentSearchTerm: ->
      Backbone.Syphon.serialize(this).search_term

    performSearch: (e) ->
      e.preventDefault()
      @currentSearchTerm = @getCurrentSearchTerm()
      search_options =
        page: 1
        remove: true
        reset: true
      @events_region.currentView.collection.search(@currentSearchTerm, search_options)