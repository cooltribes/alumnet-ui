@AlumNet.module 'AdminApp.Payments', (Payments, @AlumNet, Backbone, Marionette, $, _) ->
  class Payments.Layout extends Marionette.LayoutView
    template: 'admin/payments/templates/layout'
    className: "container-fluid no-padding"

    regions:
      filters_region: "#region_filters"
      content_region: "#region_content"

    events:
      'click .optionMenu': 'goOptionMenu'
      'click #advancedFilters': 'showFiltersAdvanced'
      'click #js-close': 'hideFiltersAdvanced'

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
      if @valueClick == "all"
        $("#advancedFilters").show()
      else
        $("#advancedFilters").hide()
      @trigger "navigate:menu", @valueClick
      @toggleLink(click)

    toggleLink: (element)->
      $(".optionMenu").removeClass("submenuSettings__item__link--activeInvoices")
      element.addClass("submenuSettings__item__link--activeInvoices")

    showFiltersAdvanced: ->
      $("#formAdvancedFilters").removeClass("hide")
      $("#advancedFilters").hide()

    hideFiltersAdvanced:->
      $("#formAdvancedFilters").addClass("hide")
      $("#advancedFilters").show()


