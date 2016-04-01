@AlumNet.module 'UsersApp.Billing', (Billing, @AlumNet, Backbone, Marionette, $, _) ->
  class Billing.Layout extends Marionette.LayoutView
    template: 'users/settings/templates/billing_container'
		childView: Billing.Child
    childViewContainer: '#billing-container'
    tagName: 'tr'

  class Billing.Child extends Marionette.ItemView
    template: 'users/settings/templates/_billing'

