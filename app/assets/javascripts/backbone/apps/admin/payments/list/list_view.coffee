@AlumNet.module 'AdminApp.ListPayments', (ListPayments, @AlumNet, Backbone, Marionette, $, _) ->
	class ListPayments.Payment extends Marionette.ItemView
    template: 'admin/payments/list/templates/_list'
    tagName: "tr"

  class ListPayments.Layout extends Marionette.CompositeView
    template: 'admin/payments/list/templates/list_container'
    childView: ListPayments.Payment 
    childViewContainer: '#list-container'