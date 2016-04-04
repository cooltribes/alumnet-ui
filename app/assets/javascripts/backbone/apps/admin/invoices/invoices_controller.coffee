@AlumNet.module 'AdminApp.Invoices', (Invoices, @AlumNet, Backbone, Marionette, $, _) ->
  class Invoices.Controller
    showLayoutInvoices: -> 
      @layoutView = new Invoices.Layout
      AlumNet.mainRegion.show(@layoutView)