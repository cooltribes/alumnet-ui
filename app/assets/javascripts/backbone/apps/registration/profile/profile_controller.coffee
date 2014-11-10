@AlumNet.module 'RegistrationApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
  class Profile.Controller

    createProfile: ->

      # creating layout
      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.request 'get:current_user' #, refresh: true     

      profile = user.profile
      # console.log profile

      profileForm = @getFormView(profile)

      # console.log profile
      layoutView.form_region.show(profileForm)

      profileForm.on "form:submit", (model, data)->        
        if model.isValid(true)
          options_for_save =
            wait: true
            contentType: false
            processData: false
            data: data
            #model return id == undefined, this is a temporally solution.
            success: (model, response, options)->
              #Pass to step 2 of registration process
              AlumNet.trigger "registration:contact"
          model.save(data, options_for_save)
      

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")

    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")

    getFormView: (profile) ->
      new Profile.Form
        model: profile