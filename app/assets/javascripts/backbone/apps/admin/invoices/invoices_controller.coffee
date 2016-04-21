@AlumNet.module 'AdminApp.Invoices', (Invoices, @AlumNet, Backbone, Marionette, $, _) ->
  class Invoices.Controller
    showLayoutInvoices: (optionMenu)-> 
      @optionMenu = optionMenu
      @layoutView = new Invoices.Layout
        option: @optionMenu
      AlumNet.mainRegion.show(@layoutView)
      @showAll()

    showAll: ->
      view = new AlumNet.AdminApp.ListInvoices.Layout
      @layoutView.content_region.show(view)