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
        when "experience_b"
          alert "experience professional"
        else
          false
          # alert "not experience"          
      
    
    experienceAiesec: ->
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.request 'get:current_user' #, refresh: true     

      profile = user.profile

      experiences = new AlumNet.Entities.ExperienceCollection [
          {
            first: true
            exp_type: 0
          },
      ]

      #get the view according to exp_type 1:alumni
      formView = @getFormView(experiences, profile, 0)
      
      layoutView.form_region.show(formView)

      formView.on "form:submit", (profileModel)->        
        #every model in the collection is valid
        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity
          else
            captureDates(model)            

          
        if validColection
          
          options_for_save =
            wait: true           
            success: (model, response, options)->
              #Pass to step 3 of registration process
              AlumNet.trigger "registration:show"

          exps = _.pluck(@collection.models, 'attributes');
          
          profileModel.set "experiences_attributes", exps                    

          
          profileModel.save(profileModel.attributes, options_for_save)
    

    experienceAlumni: ->
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.request 'get:current_user' #, refresh: true     

      profile = user.profile

      experiences = new AlumNet.Entities.ExperienceCollection [
          {
            first: true
            exp_type: 1
          },
      ]

      #get the view according to exp_type 1:alumni
      formView = @getFormView(experiences, profile, 1)
      
      layoutView.form_region.show(formView)

      formView.on "form:submit", (profileModel)->        
        #every model in the collection is valid
        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity
          else
            captureDates(model)

          
        if validColection
          
          options_for_save =
            wait: true
           
            success: (model, response, options)->
              #Pass to step 3 of registration process
              console.log "finished alumni experience"
              AlumNet.trigger "registration:show"

          exps = _.pluck(@collection.models, 'attributes');
          profileModel.set "experiences_attributes", exps
          # profileModel.set "register", exps

          
          profileModel.save(profileModel.attributes, options_for_save)

    experienceAcademic: ->
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.request 'get:current_user' #, refresh: true     

      profile = user.profile

      experiences = new AlumNet.Entities.ExperienceCollection [
          {
            first: true
            exp_type: 2
          },
      ]

      #get the view according to exp_type 1:alumni
      formView = @getFormView(experiences, profile, 2)
      
      layoutView.form_region.show(formView)

      formView.on "form:submit", (profileModel)->        
        #every model in the collection is valid
        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity
          else
            captureDates(model)

          
        if validColection
          
          options_for_save =
            wait: true
           
            success: (model, response, options)->
              #Pass to step 3 of registration process
              AlumNet.trigger "registration:show"

          exps = _.pluck(@collection.models, 'attributes');
          profileModel.set "experiences_attributes", exps
          # profileModel.set "register", exps

          console.log profileModel
          # profileModel.save(profileModel.attributes, options_for_save)




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



    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")      

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
       
        
