@AlumNet.module 'MeetupExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.MeetupExchange extends Marionette.LayoutView
    template: 'meetup_exchange/main/templates/layout'
    
    regions:
      meetup_region: '#meetup-region'

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
        when "discoverJobExchange"
          return 0
        
    templateHelpers: ->
      classOf: (step) =>
        @class[step]

  class Main.ModalMeetup extends Backbone.Modal
    template: 'meetup_exchange/main/templates/modal'
    cancelEl: '#js-close'