@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'container'

    initialize: (options)->
      document.title = 'AlumNet - Become a member'
      @current_user = options.current_user
    
    events:
      'click .js-item': 'startPayment'

    startPayment: (e)->
      e.preventDefault()
      data = {"subscription_id": e.target.id}
      AlumNet.trigger 'payment:checkout', data, 'subscription'