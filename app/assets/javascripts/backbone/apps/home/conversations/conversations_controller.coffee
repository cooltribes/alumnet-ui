@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.Controller
    showCurrentUserConversations: (conversation_id, subject, user)->
      layout = new Conversations.Layout
        conversation_id: conversation_id
        subject: subject
        user: user
      AlumNet.mainRegion.show(layout)
      AlumNet.execute('render:home:submenu')

