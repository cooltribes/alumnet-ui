@AlumNet.module 'ChatApp.Chat', (Chat, @AlumNet, Backbone, Marionette, $, _) ->
  class Chat.Controller
    init: ->
      chatLayout = new AlumNet.ChatApp.Chat.Layout
      AlumNet.mainRegion.show(chatLayout)
