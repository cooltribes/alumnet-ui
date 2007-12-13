@AlumNet.module 'RegistrationApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
  class Profile.Controller

    createProfile: ->
      
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      
      layoutView.form_region.show(@getFormView())
    

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")      

    getFormView: (groups) ->
      new Profile.Form      