@AlumNet.module 'BusinessExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.BusinessExchange extends Marionette.LayoutView
    template: 'business_exchange/main/templates/layout'
    
    regions:
      cards_region: '#groups-region'
      #filters_region: '#filters-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .js-search': 'search'
      #'click .optionMenuRight' : 'goOptionMenuRight'
   
    initialize: (options)->
      @current_user = options.current_user
      @optionMain = options.option
      @opcionInteger(options.option)
      @tab = @opcionInteger(options.option)
      @class = [
        "", "", ""
      ]
      @class[parseInt(@tab)] = "--active"

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "businessProfiles"
          return 0
        when "yourTasks"
          return 1
        
    templateHelpers: ->
      current_user_id: @current_user.id
      classOf: (step) =>
        @class[step]

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      @valueClick = click.attr("data-menu")
      @optionMain = @valueClick
      @trigger "navigate:menu:programs",@valueClick
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    search: (e)->
      e.preventDefault()
      value = $('#search_term').val()
      if @optionMain == "businessProfiles"
        @trigger('business:search', { q: { m: 'or', profile_first_name_cont_any: value.split(" "), profile_last_name_cont_any: value.split(" ") } } )
      else if @optionMain == "yourTasks"
        @trigger('business:search', { q: { name_cont: value } } )

