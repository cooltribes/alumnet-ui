@AlumNet.module 'RegistrationApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
  class Profile.Controller

    showProfile: ->

      # creating layout
      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.request 'get:current_user' #, refresh: true

      profile = user.profile

      profileForm = @getFormView(profile)

      layoutView.form_region.show(profileForm)

      AlumNet.execute('render:groups:submenu')


      profileForm.on 'form:submit', (model, data)->
        if model.isValid(true)
          options_for_save =
            wait: true
            contentType: false
            processData: false
            data: data
            success: (model, response, options)->
              #Pass to step 2 of registration process
              AlumNet.trigger 'registration:contact'
          model.save(data, options_for_save)


    getLayoutView: ->
      AlumNet.request('registration:shared:layout')

    getSidebarView: ->
      AlumNet.request('registration:shared:sidebar', 1)

    getFormView: (profile) ->
      new Profile.Form
        model: profile