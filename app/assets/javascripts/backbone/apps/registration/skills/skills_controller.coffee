@AlumNet.module 'RegistrationApp.Skills', (Skills, @AlumNet, Backbone, Marionette, $, _) ->
  class Skills.Controller

    showSkills: ->            
      
      # creating layout for experience type 3
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView(4))

      user = AlumNet.request 'get:current_user' #, refresh: true     

      profile = user.profile

      languages = new AlumNet.Entities.ProfileLanguageCollection [
          {
            first: true            
            level: 3            
          },
      ]
      
      #get the view according to exp_type 1:alumni
      formView = @getFormView(languages, profile)
      
      layoutView.form_region.show(formView)
      
      #AlumNet.execute('render:groups:submenu')      
      

      formView.on "form:submit", (profileModel, skillsData)->        
        #every model in the collection is valid

        validColection = true

        _.forEach @collection.models, (model, index, list)->
          if !(validity = model.isValid(true))
            validColection = validity          
        

        
        if validColection
          
          options_for_save =
            wait: true
           
            success: (model, response, options)->
              #Pass to step 3 of registration process
              AlumNet.trigger "registration:approval"

          languages = _.pluck(@collection.models, 'attributes');
          
          profileModel.set "languages_attributes", languages
          
          profileModel.set "skills_attributes", skillsData          

          # console.log profileModel
          profileModel.save(profileModel.attributes, options_for_save)

      

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: (step) ->
      AlumNet.request("registration:shared:sidebar", step)      

    getFormView: (collection, profileModel) ->      

      new Skills.LanguageList
        collection: collection
        model: profileModel
        
       
        
