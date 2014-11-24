@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.Controller
    showCurrentUserConversations: ->
      conversations = AlumNet.request('conversations:get', {})

      layout = new Conversations.Layout

      conversationsView = new Conversations.ConversationsView
        collection: conversations

      replyView = new Conversations.ReplyView
      newConversationView = new Conversations.NewConversationView

      AlumNet.mainRegion.show(layout)
      layout.conversations.show(conversationsView)
      # Load a new conversation by defaul
      layout.messages.show(newConversationView)

      reRenderReplyView = (model, collection)->
        replyView.model = model
        replyView.collection = collection
        collection.fetch
          success: ->
            layout.messages.show(replyView, { preventDestroy: true, forceShow: true })

      # Reload the new conversation view when link new is clicked
      layout.on 'new:conversation', ->
        layout.messages.show(newConversationView, { preventDestroy: true })


      # if reply is send
      replyView.on 'reply:submit', (data)->
        conversation = replyView.model
        message = AlumNet.request('messages:new', conversation.id)
        message.save data,
          success: (model, response, options) ->
            # PROBLEM: Here is binding the collection with view.. but only for the first time
            # then the other view are not updated when a model is added
            # replyView.collection.add(model)
            ##TEMPORAL SOLUTION: This is too dirty. The best way is the above
            reRenderReplyView(conversation, conversation.messages)

      # if a conversation is clicked then set a reply view with the model and collection
      conversationsView.on 'childview:conversation:clicked', (childView)->
        conversation = childView.model
        messages = conversation.messages
        reRenderReplyView(conversation, messages)

      # if new conversation is send
      newConversationView.on 'conversation:submit', (data)->
        conversation = AlumNet.request('conversations:new')
        conversation.save data,
          success: (model, response, options) ->
            # when is saved the conversation goto conversationsView and render a replyView with it.
            conversationsView.collection.add(model)
            messages = model.messages
            reRenderReplyView(model, messages)

