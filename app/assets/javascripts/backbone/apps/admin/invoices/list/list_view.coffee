@AlumNet.module 'AdminApp.ListInvoices', (ListInvoices, @AlumNet, Backbone, Marionette, $, _) ->
	class ListInvoices.Invoice extends Marionette.ItemView
    template: 'admin/invoices/list/templates/_list'

  class ListInvoices.Layout extends Marionette.LayoutView
    template: 'admin/invoices/list/templates/list_container'
    childView: ListInvoices.Invoice 
    childViewContainer: '#list-container'

