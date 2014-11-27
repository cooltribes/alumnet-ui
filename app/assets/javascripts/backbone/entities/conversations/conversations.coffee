@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Conversation extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/me/conversations'

    initialize: ->
      @messages = new Entities.MessagesCollection
      @messages.url = AlumNet.api_endpoint + '/me/conversations/' + @get('id') + '/receipts'

      @on 'change', ->
        @messages.url = AlumNet.api_endpoint + '/me/conversations/' + @get('id') + '/receipts'

  class Entities.ConversationsCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/me/conversations'
    model: Entities.Conversation

  class Entities.Message extends Backbone.Model

  class Entities.MessagesCollection extends Backbone.Collection
    model: Entities.Message

  API =
    getNewMessage: (conversation_id)->
      message = new Entities.Message
      message.url = AlumNet.api_endpoint + '/me/conversations/' + conversation_id + '/receipts'
      message

    getNewConversation: ->
      new Entities.Conversation

    getConversations: (querySearch)->
      conversations = new Entities.ConversationsCollection
      conversations.fetch
        data: querySearch
      conversations


  AlumNet.reqres.setHandler 'messages:new', (conversation_id)->
    API.getNewMessage(conversation_id)

  AlumNet.reqres.setHandler 'conversations:new', ->
    API.getNewConversation()

  AlumNet.reqres.setHandler 'conversations:get', (querySearch)->
    API.getConversations(querySearch)