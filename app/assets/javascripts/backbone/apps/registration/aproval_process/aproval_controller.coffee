@AlumNet.module 'RegistrationApp.Aproval', (Aproval, @AlumNet, Backbone, Marionette, $, _) ->
  class Aproval.Controller

    createAproval: ->
     
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSideView())
      
      user = AlumNet.request 'get:current_user' #, refresh: true     

      profile = user.profile
      
      contactForm = @getFormView(profile)
      layoutView.form_region.show(contactForm)      
      #layoutView.form_region.show(@getFormView())

      # acctually show layout in default (main) region

    getLayoutView: ->
      # List.Layout is in the same module but defined in list_view.coffee file
      AlumNet.request("registration:shared:layout")  

    # instantiate views defined in list_view.coffee
    getSideView: ->
      AlumNet.request("registration:shared:sidebar")

    getFormView: (profile) ->
      new Aproval.Form
        model: profile   