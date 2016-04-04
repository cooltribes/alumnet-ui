@AlumNet.module 'AdminApp.Invoices', (Invoices, @AlumNet, Backbone, Marionette, $, _) ->
  class Invoices.Layout extends Marionette.LayoutView
    template: 'admin/invoices/templates/layout'

    # regions:
    #   filters_region: "region_filters"
    #   content_region: "#region_content"


    events:
      'click .optionMenu': 'goOptionMenu'

    initialize: (options)->
      @opcionInteger(options.option)
      @tab = @opcionInteger(options.option)
      @class = [
        "", "", "", ""
      ]
      @class[parseInt(@tab)] = "--activeInvoices"

    opcionInteger: (optionMenu)->
      switch optionMenu
        when "all"
          return 0
        when "paid"
          return 1
        when "pending"
          return 2
        when "canceled"
          return 3
     
    templateHelpers: ->
      classOf: (step) =>
        @class[step]

    goOptionMenu: (e)->
      e.preventDefault()
      click = $(e.currentTarget)
      @valueClick = click.attr("data-menu")
      @trigger "navigate:menu", @valueClick
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenu").removeClass("submenuSettings__item__link--activeInvoices")
      element.addClass("submenuSettings__item__link--activeInvoices")
