@AlumNet.module 'RegistrationApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
  class Profile.Controller

    createProfile: ->

      # creating layout
      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.request 'get:current_user'

      user.fetch()

      profile = user.profile


      # console.log profile.attributes

      # console.log "id de User"
      # console.log user.get("id")
      # console.log user.profile

      # console.log profile

      # createForm = new Profile.Form
      #   model: profile

      layoutView.form_region.show(@getFormView(profile))

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")

    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")

    getFormView: (profile) ->
      new Profile.Form
        model: profile