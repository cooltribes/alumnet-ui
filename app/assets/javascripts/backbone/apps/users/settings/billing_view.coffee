@AlumNet.module 'UsersApp.Billing', (Billing, @AlumNet, Backbone, Marionette, $, _) ->
  class Billing.BillView extends Marionette.ItemView
    template: 'users/settings/templates/_billing'
    tagName: 'tr'

  class Billing.Layout extends Marionette.LayoutView
    template: 'users/settings/templates/billing_container'
    childView: Billing.BillView
    childViewContainer: '#billing-container'
    
  class Billing.DetailsBill extends Marionette.LayoutView
    template: 'users/settings/templates/detail_bill'