@AlumNet.module "HeaderApp", (HeaderApp, @AlumNet, Backbone, Marionette, $, _) ->  

  API =
    showUnauthenticatedHeader: ->
      new HeaderApp.Show.ControllerNoAuth
        region: App.header_region

    showAuthenticatedHeader: ->
      new HeaderApp.Show.ControllerAuth
        region: App.header_region

    showAdminHeader: ->
      new HeaderApp.Admin.Controller
        region: App.header_region

    showSaasAdminHeader: ->
      new HeaderApp.SaasAdmin.Controller
        region: App.header_region
  
  AlumNet.commands.setHandler 'header:init:regular', ->
    API.showAuthenticatedHeader()  

  HeaderApp.on "start", ->
    API.showAuthenticatedHeader()