@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.Controller
    showCurrentUserConversations: ->
      conversations = AlumNet.request('conversations:get', {})
      conversation = AlumNet.request('conversations:new')

      layout = new Conversations.Layout
      conversationsView = new Conversations.ConversationsView
        collection: conversations

      messagesView = new Conversations.MessagesView
        model: conversation

      AlumNet.mainRegion.show(layout)
      layout.conversations.show(conversationsView)
      layout.messages.show(messagesView)

      messagesView.on 'conversation:submit', (data)->
        conversation = messagesView.model
        console.log conversation
        conversation.save(data)

      conversationsView.on 'childview:conversation:clicked', (childView)->
        conversation = childView.model
        messagesView.model = conversation

      messagesView.on 'reply:submit', (data)->
        conversation = messagesView.model
        message = AlumNet.request('messages:new', conversation.id)
        message.save(data)
