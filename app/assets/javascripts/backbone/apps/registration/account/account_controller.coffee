@AlumNet.module 'RegistrationApp.Account', (Account, @AlumNet, Backbone, Marionette, $, _) ->
  class Account.Controller

    showRegister: ->

      #Check the status of the register for taking the user to the correspondant view
      user = AlumNet.request 'get:current_user'
      step = user.profile.get("register_step")
           
      console.log step     

      switch step
        when "initial"          
          @createProfile()
        when "profile"
          @createContact()
        when "contact", "experience_a", "experience_b", "experience_c"
          @createExperience(step)
        when "experience_d"
          @createSkills()
        when "skills"
          @createApproval()
        else
          false

    createProfile: ->            
      controller = new AlumNet.RegistrationApp.Profile.Controller      
      controller.showProfile()

    createContact: ->            
      controller = new AlumNet.RegistrationApp.Contact.Controller      
      controller.showContact()
      
    createExperience: (step)->            
      controller = new AlumNet.RegistrationApp.Experience.Controller      
      controller.showExperience(step)

    createSkills: ->            
      controller = new AlumNet.RegistrationApp.Skills.Controller      
      controller.showSkills()

    createApproval: ->     
      controller = new AlumNet.RegistrationApp.Approval.Controller      
      controller.showApproval()
      
         