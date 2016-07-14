@AlumNet.module 'ChatApp.Chat', (Chat, @AlumNet, Backbone, Marionette, $, _) ->
  class Chat.Controller
    showChatLayout: ->
      console.log "entro"
      chatLayout = new Chat.Layout
      AlumNet.chatRegion.show(chatLayout)