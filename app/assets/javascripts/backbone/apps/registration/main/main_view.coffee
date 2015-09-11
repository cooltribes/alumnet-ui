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
      @side_region.show(@getSidebarView(@registration_steps, @indexStep + 1))
      @form_region.show(@currentView) if @currentView

    getSidebarView: (registration_steps, step)->
      AlumNet.request('registration:shared:sidebar', registration_steps, step)

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
        when "languages_and_skills"
          @languages_and_skills(step)
        else
          null

    basic_information: (step)->
      new Main.BasicInformation
        model: AlumNet.current_user.profile
        layout: @
        step: step

    languages_and_skills: ()->
      
      #Languages
      collection = if gon.linkedin_profile && gon.linkedin_profile.languages.length > 0
        languagesCollection = new AlumNet.Entities.ProfileLanguageCollection
        _.forEach gon.linkedin_profile.languages, (elem, index, list)->
          languagesCollection.add(new AlumNet.Entities.ProfileLanguage {name: elem.name})
        languagesCollection
      else
        new AlumNet.Entities.ProfileLanguageCollection [{first: true, level: 3}]

      #Skills
      if gon.linkedin_profile && gon.linkedin_profile.skills.length > 0
        linkedin_skills = _.pluck(gon.linkedin_profile.skills, 'name')
      else
        linkedin_skills = []
      
      languagesView = new Main.LanguageList
        linkedin_skills: linkedin_skills
        collection: collection
        model: AlumNet.current_user.profile
        layout: @
        

      languagesView                  

