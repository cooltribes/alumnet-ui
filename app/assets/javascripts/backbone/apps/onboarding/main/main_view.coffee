@AlumNet.module 'OnboardingApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->

  class Main.Layout extends Marionette.LayoutView
    template: 'onboarding/main/templates/layout'
    className: 'container-fluid'
    regions:
      form_region: '#form-region'

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
      @form_region.empty()
      @form_region.show(@currentView) if @currentView

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
          @basic_information(step)
        else
          null

    basic_information: (step)->
      null
