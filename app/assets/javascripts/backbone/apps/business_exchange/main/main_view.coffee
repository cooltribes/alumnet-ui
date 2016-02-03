@AlumNet.module 'BusinessExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.BusinessExchange extends Marionette.LayoutView
    template: 'business_exchange/main/templates/layout'
    
    regions:
      cards_region: '#groups-region'
      #filters_region: '#filters-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      #'click .optionMenuRight' : 'goOptionMenuRight'
   
    initialize: (options)->
      @current_user = options.current_user
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
      valueClick = click.attr("data-menu")
      console.log valueClick
      @trigger "navigate:menu:programs",valueClick
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")
