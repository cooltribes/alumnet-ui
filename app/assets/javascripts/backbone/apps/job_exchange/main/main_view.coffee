@AlumNet.module 'JobExchangeApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.JobExchange extends Marionette.LayoutView
    template: 'job_exchange/main/templates/layout'
    
    regions:
      jobs_region: '#jobs-region'

    events:
      'click .optionMenuLeft': 'goOptionMenuLeft'
      'click .js-search': 'search'
      'click @ui.modalJobExchange': 'showModal'

    ui:
      'modalJobExchange':'#js-modal-job'

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
        when "myApplications"
          return 1
        when "manageJobExchange"
          return 2
        
    templateHelpers: ->
      classOf: (step) =>
        @class[step]

    goOptionMenuLeft: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      @valueClick = click.attr("data-menu")
      @optionMain = @valueClick
      @trigger "navigate:menu:job",@valueClick
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenuLeft").removeClass("submenu__item__link--active")
      element.addClass("submenu__item__link--active")

    search: (e)->
      e.preventDefault()
      value = $('#search_term').val()
      @trigger('jobs:search', { q: { name_cont: value } } )

    showModal: (e)->
      e.preventDefault()
      modal = new Main.ModalJob
      $('#container-modal-job').html(modal.render().el)

  class Main.ModalJob extends Backbone.Modal
    template: 'job_exchange/main/templates/modal'
    cancelEl: '#js-close'