@Profinda.module "HeaderApp", (HeaderApp, @AlumNet, Backbone, Marionette, $, _) ->
  @startWithParent = false

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

  App.commands.setHandler 'header:init:admin', ->
    API.showAdminHeader()

  App.commands.setHandler 'header:init:saas_admin', ->
    API.showSaasAdminHeader()

  App.commands.setHandler 'header:init:regular', ->
    API.showAuthenticatedHeader()

  App.vent.on 'header:notification:clicked', (notification) ->
    if notification.get('category_type') == 'message'
      # '/conversations/ID'
      conversation_id = notification.get('url_address').match(/\d+/)?[0]
      if conversation_id?
        App.commands.execute 'swipe:show_conversation',
          conversation_id: conversation_id
    else
      # onclick (onNotificationClicked) we preventDefault so trigger navigation here
      App.navigate notification.get('url_address'), trigger: true

  HeaderApp.on "start", ->
    if App.current_user
      API.showAuthenticatedHeader()
    else
      API.showUnauthenticatedHeader()
