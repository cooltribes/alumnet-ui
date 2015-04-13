@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.Controller
    showCurrentUserConversations: (conversation_id, user)->
      conversations = AlumNet.request('conversations:get', {})
      layout = new Conversations.Layout

      conversationsView = new Conversations.ConversationsView
        collection: conversations

      replyView = new Conversations.ReplyView
      newConversationView = new Conversations.NewConversationView
        recipient: user

      AlumNet.mainRegion.show(layout)
      layout.conversations.show(conversationsView)

      if conversation_id == undefined
        # Load a new conversation by defaul
        layout.messages.show(newConversationView)
      else
        conversations.on 'fetch:success', ->
          conversation = conversations.get(conversation_id)
          messages = conversation.messages
          reRenderReplyView(conversation, messages)

      AlumNet.execute('render:home:submenu')

      reRenderReplyView = (model, collection)->
        replyView.model = model
        replyView.collection = collection
        collection.fetch
          success: ->
            layout.messages.show(replyView, { preventDestroy: true, forceShow: true })

      # Reload the new conversation view when link new is clicked
      layout.on 'new:conversation', ->
        newConversationView.recipient = undefined
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

      # REFACTORIZAR!!!!
      replyView.on 'childview:click:read', (childView)->
        conversation = replyView.model
        message = childView.model
        message.url = AlumNet.api_endpoint + '/me/conversations/' + conversation.id + '/receipts/' + message.id + '/read'
        message.save {},
          success: ->
            replyView.remNewMessage()
            childView.toggleLink()
            conversationsView.render()

      replyView.on 'childview:click:unread', (childView)->
        conversation = replyView.model
        message = childView.model
        message.url = AlumNet.api_endpoint + '/me/conversations/' + conversation.id + '/receipts/' + message.id + '/unread'
        message.save {},
          success: ->
            replyView.sumNewMessage()
            childView.toggleLink()
            conversationsView.render()

      # if a conversation is clicked then set a reply view with the model and collection
      conversationsView.on 'childview:conversation:clicked', (childView)->
        conversation = childView.model
        messages = conversation.messages
        AlumNet.navigate("conversations/#{conversation.id}")
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

