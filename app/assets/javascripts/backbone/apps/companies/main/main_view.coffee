@AlumNet.module 'CompaniesApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.CompaniesView extends Marionette.LayoutView
    template: 'companies/main/templates/layout'

    regions:
      companies_region: '#companies-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .js-changeGrid' : 'changeGridView'
      'click .js-viewCard': 'viewCard'
      'click .js-viewList': 'viewList'
      'submit #search-form': 'basicSearch'

    initialize: (options)->
      @stepMenu = options.option
      @opcionInteger(options.option)
      @tab = @opcionInteger(options.option)
      @class = [
        "", "", ""
      ]
      @class[parseInt(@tab)] = "--active"

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
      @stepMenu = @valueClick
      @trigger "navigate:menu:companies",@valueClick
      @toggleLink(click)

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

    basicSearch: (e)->
      e.preventDefault()
      value = $('#search_term').val()
      if @stepMenu == "discoverCompanies" || @stepMenu == "manageCompanies"
        @trigger('search', { q: { name_cont: value } })
      else if @stepMenu == "myCompanies"
        @trigger('search', { q: { name_cont: value, company_admins_user_id_eq: AlumNet.current_user.id, status_eq: 1 } })