@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->

  class Suggestions.Layout extends Marionette.LayoutView
    template: 'onboarding/suggestions/templates/layout'
    regions:
      navbar_region: '#navbar-region'
      suggestion_region: '#suggestion-region'

    initialize: ->
      @step = 1
      @maxSteps = 3

    templateHelpers: ->
      step: @step
      isFirstStep: @isFirstStep()
      isLastStep: @isLastStep()

    ui:
      'prevLink': '.js-prev'
      'nextLink': '.js-next'
      'finishLink': '.js-finish'

    events:
      'click @ui.prevLink': 'prevClicked'
      'click @ui.nextLink': 'nextClicked'
      'click @ui.finishLink': 'finishClicked'

    onRender: ->
      @Menu = @showNavbar(@step)
      @navbar_region.empty()
      @navbar_region.show(@Menu) if @Menu
      @currentView = @getCurrentView(@step)
      @suggestion_region.empty()
      @suggestion_region.show(@currentView) if @currentView

    isFirstStep: ->
      @step == 1

    isLastStep: ->
      @step == @maxSteps

    prevClicked: (e)->
      e.preventDefault()
      unless @isFirstStep()
        @goToPrev()

    nextClicked: (e)->
      e.preventDefault()
      unless @isLastStep()
        @goToNext()

    finishClicked: (e)->
      e.preventDefault()
      AlumNet.current_user.save { show_onboarding: false },
        success: ->
          AlumNet.execute('header:show:regular')
          AlumNet.trigger('home')

    goToPrev: ->
      @step -= 1
      @render()

    goToNext: ->
      @step += 1
      @render()

    getCurrentView: (step)->
      switch step
        when 1
          @groups(step)
        when 2
          @alumni(step)
        when 3
          @member(step)
        else
          null

    showNavbar: (step)->
      new Suggestions.Navbar
        step: step

    groups: (step)->
      new Suggestions.Groups

    alumni: (step)->
      new Suggestions.Alumni

    member: (step)->
      # subscriptions = AlumNet.request('product:entities', {q: { feature_eq: 'subscription', status_eq: 1 }})
      # subscriptions.on 'fetch:success', (collection)->
      #   console.log collection
        # new Suggestions.SubscriptionsView
        #   current_user: AlumNet.current_user
        #   collection: collection
      new Suggestions.Member