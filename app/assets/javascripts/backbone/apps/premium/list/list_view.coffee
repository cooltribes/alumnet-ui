@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'container'

    initialize: (options)->
      document.title = 'AlumNet - Become a member'
      @current_user = options.current_user
    
    events:
      'click button.js-submit': 'submitClicked'

    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      AlumNet.trigger 'payment:checkout' , data