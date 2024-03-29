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


      if @currentView? #Solo si es un paso valido
        profile = AlumNet.current_user.profile
        stepActual = _.indexOf(@registration_steps, profile.get("register_step"))
        stepActual = parseInt(stepActual)
        indexStep = parseInt(indexStep)
        AlumNet.navigate("registration/#{@step}") #For url to be shown according to step
        @side_region.empty()
        @form_region.empty()
        @side_region.show(@getSidebarView(@registration_steps, @indexStep + 1))

        @form_region.show(@currentView) if @currentView

    navigateStep: (step, indexStep) ->
      currentView = @getCurrentView(step)
      profile = AlumNet.current_user.profile
      stepActual = _.indexOf(@registration_steps, profile.get("register_step"))
      indexStep = parseInt(indexStep)

      if currentView? && stepActual >= indexStep #Solo si es un paso valido al que el usuario pueda ir

        @step = step
        @indexStep = indexStep
        @onRender()
        @render()
      else
        indexStep = indexStep + 1
        stepActual = stepActual + 1
        message = "You can't access step " + indexStep + " until step " + stepActual + " is completed"
        $.growl.error({ message: message })
        @render()


    getSidebarView: (registration_steps, step)->
      sidebarView = AlumNet.request('registration:shared:sidebar', registration_steps, step)
      layout = @
      sidebarView.on  "navigate:registration", (valueStep, valueIndexStep) ->
        valueIndexStep = parseInt(valueIndexStep)

        if valueIndexStep >= layout.indexStep
          indexStep = parseInt(valueIndexStep)
          unless layout.isLastStep()

            layout.currentView.saveStepData(valueStep, valueIndexStep) if layout.currentView
        else
          layout.navigateStep(valueStep, valueIndexStep)

      sidebarView

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
      @_moveToNextStep()
      @render()

    getCurrentView: (step)->
      # Here is the own implementation to get data and view to show in form_section
      switch step
        when "basic_information"
          @basic_information(step)
        when "languages_and_skills"
          @languages_and_skills()
        when "aiesec_experiences"
          @aiesec_experiences()
        when "completed"
          if AlumNet.current_user.profile.get('created_by_admin')
            AlumNet.trigger "registration:activate:user"
          else
            @approval_process()

            #@approval_process_regionForm()
            #@approval_process_region()
        else
          null


    _moveToNextStep: ()->
      profile = AlumNet.current_user.profile
      step = profile.get("register_step")

      #si el usuario avanza en el proceso o solo navega a traves
      if step == @step

        Backbone.ajax
          url: AlumNet.api_endpoint + "/me/registration"
          method: "put"
          async: false
          success: (data)->
            step = data.current_step
          error: (data)->
            $.growl.error { message: data.status }
        profile.set("register_step", step)

        @step = step
        @indexStep = _.indexOf(@registration_steps, @step)
      else
        @indexStep += 1
        @step = @registration_steps[@indexStep]


    basic_information: (step)->
      new Main.BasicInformation
        model: AlumNet.current_user.profile
        layout: @
        step: step


    languages_and_skills: ()->
      profile = AlumNet.current_user.profile
      #Languages
      collection = if gon.linkedin_profile && gon.linkedin_profile.languages.length > 0
        languagesCollection = new AlumNet.Entities.ProfileLanguageCollection
        _.forEach gon.linkedin_profile.languages, (elem, index, list)->
          languagesCollection.add(new AlumNet.Entities.ProfileLanguage {name: elem.name})
        languagesCollection
      else
        user_languages = new AlumNet.Entities.ProfileLanguageCollection []
        user_languages.url = AlumNet.api_endpoint + '/profiles/' + profile.id + "/language_levels"
        user_languages.fetch
          wait: true
          success: (collection)->
            if collection.length == 0
              collection.add({first: true, level: 3})
        user_languages

      #Skills
      if gon.linkedin_profile && gon.linkedin_profile.skills.length > 0
        linkedin_skills = _.pluck(gon.linkedin_profile.skills, 'name')
      else
        linkedin_skills = []

      languagesView = new Main.LanguageList
        linkedin_skills: linkedin_skills
        collection: collection
        model: profile
        layout: @

      languagesView


    aiesec_experiences: ()->
      exp_type = 0 #AIESEC EXPERIENCE
      profile = AlumNet.current_user.profile

      # experiences = new AlumNet.Entities.ExperienceCollection [{first: true, exp_type: exp_type}]
      experiences = new AlumNet.Entities.ExperienceCollection
      experiences.url = AlumNet.api_endpoint + '/profiles/' + profile.id + "/experiences"
      experiences.fetch
        wait: true
        data:
          q: { exp_type_eq: 0 }
        success: (collection)->
          if collection.length == 0
            collection.add({first: true, exp_type: exp_type})
          else
            collection.at(0).set("first", true )

      new Main.ExperienceList
        collection: experiences
        model: AlumNet.current_user.profile
        exp_type: exp_type
        layout: @


    approval_process: ()->
      users = AlumNet.request('user:entities', {}, {fetch: false})
      layout_view = new Main.LayoutView
      layout_view