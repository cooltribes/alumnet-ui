@AlumNet.module 'GroupsApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.GroupsView extends Marionette.LayoutView
    template: 'groups/main/templates/layout'
    
    regions:
      groups_region: '#groups-region'
      filters_region: '#filters-region'

     events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .optionMenuRight' : 'goOptionMenuRight'
      'click .js-search': 'performSearch'
      'click .js-viewCard': 'viewCard'
      'click .js-viewList': 'viewList'

    initialize: (options)->
      @stepMenu = options.option
      @opcionInteger(@stepMenu)
      @tab = @opcionInteger(@stepMenu)
      @class = [
        "", "", ""
      ]
      @class[parseInt(@tab)] = "--active"

      if @tab == 0
        $("#filtersOpcion").removeClass("hide")
      else
        $("#filtersOpcion").addClass("hide")

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "myGroups"
          return 1
        when "groupsManage"
          return 2
        when "groupsDiscover"
          return 0

    templateHelpers: ->
      @current_user = AlumNet.current_user

      classOf: (step) =>
        @class[step]

    onRender: ->
      if @tab == 0
        $("#filtersOpcion").removeClass("hide")
      else
        $("#filtersOpcion").addClass("hide")

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      valueClickLeft = click.attr("data-menu")
      if valueClickLeft == "groupsDiscover"
        $("#filtersOpcion").removeClass("hide")
      else
        $("#filtersOpcion").addClass("hide")
      @trigger "navigate:menu:groups",valueClickLeft
      @toggleLink(click)
      
    goOptionMenuRight: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @trigger "navigate:menuRight",valueClick
      @toggleLinkRight(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    toggleLinkRight: (element)->
      $(".optionMenuRight").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      this.trigger('groups:search', this.buildQuerySearch(data.search_term))

    buildQuerySearch: (searchTerm) ->
      q:
        m: 'or'
        name_cont: searchTerm
        description_cont: searchTerm

    viewCard: (e)->
      #$("#iconList").removeClass("iconTypeGroup--active iconTypeGroup")
      #$("#iconCards").addClass("iconTypeGroup--active")
      @type = "cards"
      @trigger "click:type", @type

    viewList: (e)->
      #$("#iconCards").removeClass("iconTypeGroup--active iconTypeGroup")
      #$("#iconList").addClass("iconTypeGroup--active")
      @type = "list"
      @trigger "click:type", @type