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
            r: "nels"            
          },

      ]
        
        

      layoutView.form_region.show(@getFormView(experiences))
    

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")      

    getFormView: (experiences) ->
      new Experience.ExperienceList
        collection: experiences