@AlumNet.module 'MeetupExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.MeetupExchange extends Marionette.LayoutView
    template: 'meetup_exchange/main/templates/layout'

    regions:
      meetup_region: '#meetup-region'
      suggestions_regions: '#suggestions-regions'

    ui:
      'modalMeetups':'#js-modal-meetups'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .optionMenuRight' : 'goOptionMenuRight'
      'click @ui.modalMeetups': 'showModal'
      'click .js-search': 'search'

    initialize: (options)->
      @optionMain = options.option
      @opcionInteger(options.option)
      @tab = @opcionInteger(options.option)
      @class = [
        "", "", ""
      ]
      @class[parseInt(@tab)] = "--active"

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "discoverMeetups"
          return 0
        when "myApplications"
          return 1
        when "manageMeetups"
          return 2

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      @valueClick = click.attr("data-menu")
      @optionMain = @valueClick
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

    showModal: (e)->
      e.preventDefault()
      modal = new Main.ModalMeetups
      $('#container-modal-meetup').html(modal.render().el)

    search: (e)->
      e.preventDefault()
      value = $('#search_term').val()
      if value
        query = { q: { name_cont: value } }
      else
        query = {}
      @trigger('meetups:search', query)

  class Main.ModalMeetups extends Backbone.Modal
    template: 'meetup_exchange/main/templates/modal'
    cancelEl: '#js-close'