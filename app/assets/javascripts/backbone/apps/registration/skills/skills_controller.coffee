@AlumNet.module 'RegistrationApp.Skills', (Skills, @AlumNet, Backbone, Marionette, $, _) ->
  class Skills.Controller

    showSkills: ->
      # creating layout for experience type 3
      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView(4))

      user = AlumNet.current_user #, refresh: true

      profile = user.profile

      languages = if gon.linkedin_profile && gon.linkedin_profile.languages.length > 0
        languagesCollection = new AlumNet.Entities.ProfileLanguageCollection
        _.forEach gon.linkedin_profile.languages, (elem, index, list)->
          languagesCollection.add(new AlumNet.Entities.ProfileLanguage {name: elem.name})
        console.log languagesCollection
        languagesCollection
      else
        new AlumNet.Entities.ProfileLanguageCollection [{first: true, level: 3}]

      #get the view according to exp_type 1:alumni
      formView = @getFormView(languages, profile)

      layoutView.form_region.show(formView)


      formView.on "form:submit", (profileModel, skillsData)->
        #every model in the collection is valid

        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity

        if validColection

          languages = _.pluck(@collection.models, 'attributes');

          profileModel.set "languages_attributes", languages

          profileModel.set "skills_attributes", skillsData

          profileModel.save {},
            success: (model)->
              AlumNet.trigger "registration:approval"

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")

    getSidebarView: (step) ->
      AlumNet.request("registration:shared:sidebar", step)

    getFormView: (collection, profileModel) ->
      if gon.linkedin_profile && gon.linkedin_profile.skills.length > 0
        linkedin_skills = _.pluck(gon.linkedin_profile.skills, 'name')
      else
        linkedin_skills = []
      new Skills.LanguageList
        linkedin_skills: linkedin_skills
        collection: collection
        model: profileModel



