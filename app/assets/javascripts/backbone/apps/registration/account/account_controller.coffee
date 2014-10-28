@AlumNet.module 'RegistrationApp.Account', (Account, @AlumNet, Backbone, Marionette, $, _) ->
  class Account.Controller

    showRegister: ->
     
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      
      layoutView.form_region.show(@getFormView())

      # acctually show layout in default (main) region

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")   
    
    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar")      

    getFormView: (groups) ->
      new Account.Form
         