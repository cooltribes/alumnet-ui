@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.ConversationView extends Marionette.ItemView
    template: 'home/conversations/templates/conversation'
    triggers:
      'click .js-conversation': 'conversation:clicked'

  class Conversations.MessageView extends Marionette.ItemView
    template: 'home/conversations/templates/message'

  class Conversations.ConversationsView extends Marionette.CollectionView
    template: 'home/conversations/templates/conversations_container'
    childView: Conversations.ConversationView
    className: 'conversations-container'

  class Conversations.MessagesView extends Marionette.CompositeView
    template: 'home/conversations/templates/messages_container'
    childView: Conversations.MessageView
    childViewContainer: '.messages-container'
    templateHelpers: ->
      isConversation: @model.isNew()

    events:
      'click .js-submit':'clickedSubmit'

    clickedSubmit: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if @model.isNew()
        @trigger 'conversation:submit', data
      else
        @trigger 'reply:submit', data


  class Conversations.Layout extends Marionette.LayoutView
    template: 'home/conversations/templates/layout'
    regions:
      conversations: '#conversations-region'
      messages: '#messages-region'
