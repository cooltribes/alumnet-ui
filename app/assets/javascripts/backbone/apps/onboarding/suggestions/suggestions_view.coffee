@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->

  class Suggestions.Layout extends Marionette.LayoutView
    template: 'onboarding/suggestions/templates/layout'
    className: 'container-fluid'
    regions:
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

    events:
      'click @ui.prevLink': 'prevClicked'
      'click @ui.nextLink': 'nextClicked'

    onRender: ->
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

    groups: (step)->
      new Suggestions.Groups

    alumni: (step)->
      new Suggestions.Alumni

    member: (step)->
      new Suggestions.Member