@AlumNet.module 'RegistrationApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->
  class Contact.Controller

    showContact: ->
      
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())      

      user = AlumNet.request 'get:current_user' #, refresh: true     

      profile = user.profile

      contactForm = @getFormView(profile)
      layoutView.form_region.show(contactForm)

      AlumNet.execute('render:groups:submenu')
      

      contactForm.on "form:submit", (model)->        
        # if model.isValid(true)
          
          options_for_save =
            wait: true
            # contentType: false
            # processData: false
            # data: data
            #model return id == undefined, this is a temporally solution.
            success: (model, response, options)->
              #Pass to step 3 of registration process
              AlumNet.trigger "registration:show"
              # AlumNet.trigger "registration:experience"

          model.save(model.attributes, options_for_save)
    

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar", 2)      

    getFormView: (profile) ->
      new Contact.Form
        model: profile      