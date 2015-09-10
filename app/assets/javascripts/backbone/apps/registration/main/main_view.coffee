@AlumNet.module 'RegistrationApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->

  class Main.Layout extends Marionette.LayoutView

    template: 'registration/main/templates/layout'
    className: 'container-fluid'
    regions:
      side_region: '#sidebar-region'
      form_region: '#form-region'

    # keep up to date with the registration steps of Profile in API
    registration_steps: ["basic_information", "languages_and_skills", "aiesec_experiences", "completed"]

    initialize: (options)->
      @step = options.step
      @indexStep = _.indexOf(@registration_steps, @step)

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
      @side_region.empty()
      @form_region.empty()
      @side_region.show(@getSidebarView(@indexStep + 1))
      @form_region.show(@currentView) if @currentView

    getSidebarView: (step)->
      AlumNet.request('registration:shared:sidebar', step)

    isFirstStep: ->
      @indexStep == 0

    isLastStep: ->
      @indexStep == (@registration_steps.length - 1)

    prevClicked: (e)->
      e.preventDefault()
      unless @isFirstStep()
        @goToPrev()

    nextClicked: (e)->
      e.preventDefault()
      unless @isLastStep()
        @currentView.saveData() if @currentView

    goToPrev: ->
      @indexStep -= 1
      @step = @registration_steps[@indexStep]
      @render()

    goToNext: ->
      @indexStep += 1
      @step = @registration_steps[@indexStep]
      @render()

    getCurrentView: (step)->
      # Here is the own implementation to get data and view to show in form_section
      switch step
        when "basic_information"
          @basic_information(step)
        else
          null

    basic_information: (step)->
      new Main.BasicInformation
        model: AlumNet.current_user.profile
        layout: @
        step: step
