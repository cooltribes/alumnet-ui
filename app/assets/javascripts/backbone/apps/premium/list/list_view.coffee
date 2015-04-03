@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'col-md-8 col-md-offset-3'

    initialize: (options)->
      @current_user = options.current_user

    templateHelpers: ->
      current_user: @current_user
      #userId = AlumNet.current_user.id
      #user_id = @current_user.get('id')
      #name = 'hola'