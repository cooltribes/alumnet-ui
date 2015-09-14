@AlumNet.module 'PremiumApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->

  class List.SubscriptionsView extends Marionette.ItemView
    template: 'premium/list/templates/subscriptions'
    className: 'container'

    initialize: (options)->
      document.title = 'AlumNet - Become a member'
      @current_user = options.current_user

    ui:
      'modalMembers':'#js-modal'

    events:
      'click button.js-submit': 'submitClicked'
      'click @ui.modalMembers': 'showModal'

    showModal: (e)->
      e.preventDefault()
      modal = new List.ModalOnboarding
      $('#container-modal-members').html(modal.render().el)

    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      AlumNet.trigger 'payment:checkout' , data, 'subscription'

  class List.ModalOnboarding extends Backbone.Modal
    template: 'premium/list/templates/modal'
    cancelEl: '#js-close'