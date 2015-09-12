@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Member extends Marionette.ItemView
    template: 'onboarding/member/templates/member'

    ui:
      'buyLink': '.js-buy'

    events:
      'click @ui.buyLink': 'buyClicked'

    buyClicked: (e)->
      e.preventDefault()
      console.log "Here"
      AlumNet.current_user.save { show_onboarding: false },
        success: ->
          AlumNet.execute('header:show:regular')
          AlumNet.trigger('premium')