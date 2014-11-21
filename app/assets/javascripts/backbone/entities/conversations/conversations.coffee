@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Conversation extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/me/conversations'

    validation:
      comment:
        required: true

  class Entities.ConversationsCollection extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/me/conversations'

    model: Entities.Conversation

  API =
    getNewConversation: ->
      new Entities.Conversation

    getConversations: (querySearch)->
      conversations = new Entities.ConversationsCollection
      conversations.fetch
        data: querySearch
      conversations

  AlumNet.reqres.setHandler 'conversations:new', ->
    API.getNewConversation

  AlumNet.reqres.setHandler 'conversations:get', (querySearch)->
    API.getConversations(querySearch)