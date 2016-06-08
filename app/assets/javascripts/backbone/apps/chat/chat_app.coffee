@AlumNet.module 'ChatApp', (ChatApp, @AlumNet, Backbone, Marionette, $, _) ->
  class ChatApp.Router extends AlumNet.Routers.Base

    appRoutes:
      'chat': 'chat'

  API =
    chat: ->
      controller = new ChatApp.Chat.Controller
      controller.init()

  AlumNet.on 'chat', ->
    AlumNet.navigate('chat')
    API.chat()

  AlumNet.addInitializer ->
    new ChatApp.Router
      controller: API
