@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Subscription extends AlumNet.Shared.Views.UserView
    template: 'onboarding/member/templates/_subscription'
    className: 'col-md-4'

  class Suggestions.Member extends Marionette.CompositeView
    template: 'onboarding/member/templates/member'
    childView: Suggestions.Subscription
    childViewContainer: '.subscriptions-container'

    initialize: ->
      @collection = AlumNet.request('product:entities', {q: { feature_eq: 'subscription', status_eq: 1 }})

    ui:
      'modalMembers':'#js-modal'

    events:
      'click @ui.modalMembers': 'showModal'
      'click .js-item': 'startPayment'

    templateHelpers: ->
      user: AlumNet.current_user

    onRender: ->
      $('body,html').animate({scrollTop: 0}, 600);

    startPayment: (e)->
      e.preventDefault()
      data = {"subscription_id": e.target.id}
      AlumNet.trigger 'payment:checkout', data, 'subscription'

    showModal: (e)->
      e.preventDefault()
      modal = new Suggestions.ModalOnboarding
      $('#container-modal-members').html(modal.render().el)

  class Suggestions.ModalOnboarding extends Backbone.Modal
    template: 'onboarding/member/templates/modal'
    cancelEl: '#js-close'