@AlumNet.module 'CompaniesApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.CompaniesView extends Marionette.LayoutView
    template: 'companies/main/templates/layout'

    regions:
      companies_region: '#companies-region'
      filters_region: '#filters-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .optionMenuRight' : 'goOptionMenuRight'
      'click .js-changeGrid' : 'changeGridView'
      'click .js-viewCard': 'viewCard'
      'click .js-viewList': 'viewList'
      'submit #search-form': 'performSearch'

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

    onRender: ->
      if @tab == 0
        $("#filtersOpcion").removeClass("hide")
      else
        $("#filtersOpcion").addClass("hide")

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "discoverCompanies"
          return 0
        when "myCompanies"
          return 1
        when "manageCompanies"
          return 2

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      @valueClick = click.attr("data-menu")
      if @valueClick == "discoverCompanies"
        $("#filtersOpcion").removeClass("hide")
      else
        $("#filtersOpcion").addClass("hide")
      @stepMenu = @valueClick
      @trigger "navigate:menu:left",@valueClick
      @toggleLink(click)

    goOptionMenuRight: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      valueClick = click.attr("data-menu")
      @trigger "navigate:menu:right",valueClick
      @toggleLinkRight(click)

    toggleLinkRight: (element)->
      $(".optionMenuRight").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    viewCard: (e)->
      #$("#iconList").removeClass("iconTypeGroup--active iconTypeGroup")
      #$("#iconCards").addClass("iconTypeGroup--active")
      @type = "cards"
      @trigger "changeGrid", @type

    viewList: (e)->
      #$("#iconCards").removeClass("iconTypeGroup--active iconTypeGroup")
      #$("#iconList").addClass("iconTypeGroup--active")
      @type = "list"
      @trigger "changeGrid", @type

    getCurrentSearchTerm: ->
      Backbone.Syphon.serialize(this).search_term

    performSearch: (e) ->
      e.preventDefault()
      @currentSearchTerm = @getCurrentSearchTerm()
      search_options =
        page: 1
        remove: true
        reset: true
      @companies_region.currentView.collection.search(@currentSearchTerm, search_options)

    basicSearch: (e)->
      e.preventDefault()
      value = $('#search_term').val()
      if @stepMenu == "discoverCompanies"
        data = Backbone.Syphon.serialize(this)
        @trigger 'discover:search', data.search_term, @companies_region.currentView.collection
      else if @stepMenu == "manageCompanies"
        @trigger('search', { q: { name_cont: value } })
      else if @stepMenu == "myCompanies"
        @trigger('search', { q: { name_cont: value, company_admins_user_id_eq: AlumNet.current_user.id, status_eq: 1 } })