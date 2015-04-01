@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.LayoutView
    template: 'premium/list/templates/subscriptions'
    className: 'col-md-4 col-sm-6 col-xs-12'

  