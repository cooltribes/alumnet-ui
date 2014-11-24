@AlumNet.module 'RegistrationApp.Account', (Account, @AlumNet, Backbone, Marionette, $, _) ->
  class Account.Controller

    showRegister: ->

      #Check the status of the register for taking the user to the correspondant view
      user = AlumNet.request 'get:current_user'
      step = user.profile.get("register_step")
      
      console.log "step " + step

      switch step
        when "initial"          
          @createProfile()
        when "profile"
          @createContact()
        when "contacs", "experience_a", "experience_b", "experience_c"
          @createExperience(step)
        else
          false



    createProfile: ->            
      controller = new AlumNet.RegistrationApp.Profile.Controller      
      controller.createProfile()

    createContact: ->            
      controller = new AlumNet.RegistrationApp.Contact.Controller      
      controller.createContact()
      
    createExperience: ->            
      controller = new AlumNet.RegistrationApp.Experience.Controller      
      controller.createExperience()

      

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")      

    getFormView: (groups) ->
      new Account.Form
         