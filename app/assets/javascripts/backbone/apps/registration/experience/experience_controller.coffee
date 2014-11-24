@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
  class Experience.Controller

    showExperience: ->
      user = AlumNet.request 'get:current_user'
      step = user.profile.get("register_step")
      
      switch step
        when "contact"          
          @experienceAiesec()
        when "experience_a"
          alert "experience alumni"
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
          },
      ]


      formView = @getFormView(experiences, profile)

      layoutView.form_region.show(formView)

      formView.on "form:submit", (profileModel)->        
        #every model in the collection is valid
        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity
          
        if validColection
        
          options_for_save =
            wait: true
            # contentType: false
            # processData: false
            # data: data
            #model return id == undefined, this is a temporally solution.
            success: (model, response, options)->
              #Pass to step 3 of registration process
              AlumNet.trigger "registration:experience:alumni"

          # model.save(model.attributes, options_for_save)
    

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")      

    getFormView: (experiences, profileModel) ->
      new Experience.ExperienceList
        collection: experiences
        model: profileModel
