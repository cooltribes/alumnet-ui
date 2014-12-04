@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
  class Experience.Controller

    showExperience: (step) ->

      switch step
        when "contact"
          @experienceAiesec()
        when "experience_a"
          @experienceAlumni()
        when "experience_b"
          @experienceAcademic()
        when "experience_c"
          @experiencePro()
        else
          false
          # alert "not experience"


    experienceAiesec: ->
      # creating layout
      formView = @showViews(0)

      formView.on "form:submit", (profileModel)->
        #every model in the collection is valid
        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity
          else
            captureDates(model)

        if validColection
          exps = _.pluck(@collection.models, 'attributes');
          profileModel.set "experiences_attributes", exps
          profileModel.save {},
            success: ->
              AlumNet.trigger "registration:show"


    experienceAlumni: ->
      # creating layout
      formView = @showViews(1)

      formView.on "form:submit", (profileModel)->
        #every model in the collection is valid
        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity
          else
            captureDates(model)


        if validColection
          exps = _.pluck(@collection.models, 'attributes');
          profileModel.set "experiences_attributes", exps
          profileModel.save {},
            success: ->
              AlumNet.trigger "registration:show"

    experienceAcademic: ->
      # creating layout
      formView = @showViews(2)

      formView.on "form:submit", (profileModel)->
        #every model in the collection is valid
        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity
          else
            captureDates(model)

        if validColection
          exps = _.pluck(@collection.models, 'attributes');
          profileModel.set "experiences_attributes", exps
          profileModel.save {},
            success: ->
              AlumNet.trigger "registration:show"


    experiencePro: ->
      # creating layout
      formView = @showViews(3)

      formView.on "form:submit", (profileModel)->
        #every model in the collection is valid
        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity
          else
            captureDates(model)

        if validColection
          exps = _.pluck(@collection.models, 'attributes');
          profileModel.set "experiences_attributes", exps
          profileModel.save {},
            success: ->
              AlumNet.trigger "registration:skills"


    captureDates = (model) ->
      day = 31
      month = model.get("start_month")
      year = model.get("start_year")

      if month == "1"
        day = 1
      else if month == ""
        month = 1

      model.set "start_date", "#{year}-#{month}-#{day}"

      day2 = 31
      month2 = model.get("end_month")
      year2 = model.get("end_year")
      if month2 == "1"
        day2 = 1
      else if month2 == ""
        month2 = 1

      model.set "end_date", "#{year2}-#{month2}-#{day2}"


    showViews: (exp_type) ->

      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.current_user

      profile = user.profile

      experiences = new AlumNet.Entities.ExperienceCollection [
          {
            first: true
            exp_type: exp_type
          },
      ]

      #get the view according to exp_type 1:alumni
      formView = @getFormView(experiences, profile, exp_type)

      layoutView.form_region.show(formView)

      # AlumNet.execute('render:groups:submenu')

      formView

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")

    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar", 3)

    getFormView: (experiences, profileModel, exp_type) ->
      title = "Experience in AIESEC"

      switch exp_type
        when 1
          title = "Experience in Alumni AIESEC"
        when 2
          title = "Academic Experience"
        when 3
          title = "Professional Experience"

        else
          false

      new Experience.ExperienceList
        collection: experiences
        model: profileModel
        title: title


