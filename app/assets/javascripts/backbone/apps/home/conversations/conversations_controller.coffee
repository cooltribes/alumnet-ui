@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.Controller
    showCurrentUserConversations: ->
      conversations = AlumNet.request("conversations:get", {})
