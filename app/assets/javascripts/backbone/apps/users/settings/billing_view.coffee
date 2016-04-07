@AlumNet.module 'UsersApp.Billing', (Billing, @AlumNet, Backbone, Marionette, $, _) ->
  class Billing.BillView extends Marionette.ItemView
    template: 'users/settings/templates/_billing'

  class Billing.Layout extends Marionette.LayoutView
    template: 'users/settings/templates/billing_container'
    childView: Billing.BillView
    childViewContainer: '#billing-container'
    tagName: 'tr'

  class Billing.DetailsBill extends Marionette.LayoutView
    template: 'users/settings/templates/detail_bill'
 

 

