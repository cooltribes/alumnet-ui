@AlumNet.module 'RegistrationApp.Experience', (Experience, @AlumNet, Backbone, Marionette, $, _) ->
  class Experience.Controller

    createExperience: ->
      
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      experiences = new AlumNet.Entities.ExperienceCollection [
          {
            first: true
          },
      ]

      formView = @getFormView(experiences)

      layoutView.form_region.show(formView)

      formView.on "form:submit", (collection)->        
        errors = _.some @collection, ->
          console.log "nelson"
        # if collection.isValid(true)
        console.log this
          # options_for_save =
          #   wait: true
          #   # contentType: false
          #   # processData: false
          #   # data: data
          #   #model return id == undefined, this is a temporally solution.
          #   success: (model, response, options)->
          #     #Pass to step 3 of registration process
          #     AlumNet.trigger "registration:experience"

          # model.save(model.attributes, options_for_save)
    
    

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")      

    getFormView: (experiences) ->
      new Experience.ExperienceList
        collection: experiences