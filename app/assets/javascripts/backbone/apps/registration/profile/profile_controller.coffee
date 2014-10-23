@AlumNet.module 'RegistrationApp.Profile', (Profile, @AlumNet, Backbone, Marionette, $, _) ->
  class Profile.Controller

    createProfile: ->
      
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSideView())

      
      layoutView.form_region.show(@getFormView())

      # acctually show layout in default (main) region

    getLayoutView: ->
      # List.Layout is in the same module but defined in list_view.coffee file
      new Profile.Layout  

    # instantiate views defined in list_view.coffee
    getSideView: ->
      new AlumNet.RegistrationApp.Account.Sidebar        

    getFormView: (groups) ->
      new Profile.Form      