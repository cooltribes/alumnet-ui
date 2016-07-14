@AlumNet.module 'ChatApp', (ChatApp, @AlumNet, Backbone, Marionette, $, _) ->
  class ChatApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "chat": "showChat"

  API =
    showChat: ->
      controller = new ChatApp.Chat.Controller
      controller.showChatLayout()

  AlumNet.addInitializer ->
    new ChatApp.Router
      controller: API

