@AlumNet.module 'RegistrationApp.Skills', (Skills, @AlumNet, Backbone, Marionette, $, _) ->
  class Skills.Controller

    showSkills: ->            
      
      # creating layout for experience type 3
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.request 'get:current_user' #, refresh: true     

      profile = user.profile

      languajes = new AlumNet.Entities.ProfileLanguageCollection [
          {
            first: true            
          },
      ]

      #get the view according to exp_type 1:alumni
      formView = @getFormView()
      
      layoutView.form_region.show(formView)
      
      AlumNet.execute('render:groups:submenu')      
      

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
              AlumNet.trigger "registration:skills"

          exps = _.pluck(@collection.models, 'attributes');
          profileModel.set "experiences_attributes", exps
          

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

    getFormView: ->      

      new Skills.LanguageList
        collection: experiences
        model: profileModel
        title: title
       
        
