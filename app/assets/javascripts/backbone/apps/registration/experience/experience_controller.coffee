@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
  class Experience.Controller

    showExperience: (step) ->
      switch step
        when 'contact'
          @processExperience(0)
        when 'experience_a'
          @processExperience(1)
        when 'experience_b'
          @processExperience(2)
        when 'experience_c'
          @processExperience(3)
        else
          false

    processExperience: (exp_type)->
      # creating layout
      formView = @showViews(exp_type)

      formView.on 'form:submit', (profileModel)->
        #every model in the collection is valid
        profileModel.set 'experiences_attributes', []
        validCollection = true
        experiencesAtributtes = []

        @collection.each (model)->
          if model.isValid(true)
            model.formatDates()
            experiencesAtributtes.push(model.attributes)
          else
            validCollection = false

        if validCollection
          profileModel.set 'experiences_attributes', experiencesAtributtes
          profileModel.save {},
            success: (model)->
              step = model.get('register_step')
              if step == 'experience_d'
                AlumNet.trigger 'registration:skills'
              else
                AlumNet.trigger 'registration:experience', step

      formView.on 'form:skip', (profileModel)->
        profileModel.set 'experiences_attributes', []
        profileModel.save {},
          success: (model)->
            step = model.get('register_step')
            if step == 'experience_d'
              AlumNet.trigger 'registration:skills'
            else
              AlumNet.trigger 'registration:experience', step

    showViews: (exp_type) ->

      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())
      user = AlumNet.current_user
      profile = user.profile

      if gon.linkedin_profile && gon.linkedin_profile.experiences.length > 0 && exp_type == 3
        experiences_array = []
        _.each gon.linkedin_profile.experiences, (elem, index, list)->
          experiences_array.push new AlumNet.Entities.Experience elem

      else if gon.linkedin_profile && gon.linkedin_profile.educations.length > 0 && exp_type == 2
        experiences_array = []
        _.each gon.linkedin_profile.educations, (elem, index, list)->
          experiences_array.push new AlumNet.Entities.Experience elem
      else
        experiences_array = [new AlumNet.Entities.Experience({first: true, exp_type: exp_type})]


      experiences = new AlumNet.Entities.ExperienceCollection experiences_array

      #get the view according to exp_type 1:alumni
      formView = @getFormView(experiences, profile, exp_type)
      layoutView.form_region.show(formView)
      formView

    getLayoutView: ->
      AlumNet.request('registration:shared:layout')

    getSidebarView: ->
      AlumNet.request('registration:shared:sidebar', 3)

    getFormView: (experiences, profileModel, exp_type) ->
      new Experience.ExperienceList
        collection: experiences
        model: profileModel
        exp_type: exp_type


