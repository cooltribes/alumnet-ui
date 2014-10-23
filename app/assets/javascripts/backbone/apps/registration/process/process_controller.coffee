@AlumNet.module 'RegistrationApp.Process', (Process, @AlumNet, Backbone, Marionette, $, _) ->
  class Process.Controller

    initialize: ->
     
      # creating layout
      layoutView = @getLayoutView()     
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSideView())

      
      #layoutView.form_region.show(@getFormView())

      # acctually show layout in default (main) region

    getLayoutView: ->
      # List.Layout is in the same module but defined in list_view.coffee file
      new Process.Layout  

    # instantiate views defined in list_view.coffee
    getSideView: ->
      new Process.Sidebar