@AlumNet.module 'MeetupExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.MeetupExchange extends Marionette.LayoutView
    template: 'meetup_exchange/main/templates/layout'
    
    regions:
      meetup_region: '#meetup-region'

    ui:
      'modalMeetups':'#js-modal-meetups'
    
    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click @ui.modalMeetups': 'showModal'

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
      @trigger "navigate:menu:meetup",@valueClick
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    showModal: (e)->
      e.preventDefault()
      modal = new Main.ModalMeetups
      $('#container-modal-meetup').html(modal.render().el)

  class Main.ModalMeetups extends Backbone.Modal
    template: 'meetup_exchange/main/templates/modal'
    cancelEl: '#js-close'