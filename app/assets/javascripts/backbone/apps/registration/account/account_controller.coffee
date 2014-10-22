@AlumNet.module 'RegistrationApp.Account', (Account, @AlumNet, Backbone, Marionette, $, _) ->
  class Account.Controller

    showRegister: ->
     
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSideView())

      
      layoutView.form_region.show(@getFormView())

      # acctually show layout in default (main) region

    getLayoutView: ->
      # List.Layout is in the same module but defined in list_view.coffee file
      new Account.Layout  

    # instantiate views defined in list_view.coffee
    getSideView: ->
      new Account.Sidebar        

    getFormView: (groups) ->
      new Account.Form
         