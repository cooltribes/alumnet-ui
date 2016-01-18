@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'container'

    initialize: (options)->
      AlumNet.setTitle('Become a member')
      @current_user = options.current_user

    ui:
      'modalMembers':'#js-modal'

    events:
      'click @ui.modalMembers': 'showModal'
      'click .js-item': 'startPayment'

    onRender: ->
      $('body,html').animate({scrollTop: 0}, 600);

    startPayment: (e)->
      e.preventDefault()
      data = {"subscription_id": e.target.id}
      AlumNet.trigger 'payment:cc_checkout', data, 'subscription'

    showModal: (e)->
      e.preventDefault()
      modal = new List.ModalOnboarding
      $('#container-modal-members').html(modal.render().el)

  class List.ModalOnboarding extends Backbone.Modal
    template: 'premium/list/templates/modal'
    cancelEl: '#js-close'