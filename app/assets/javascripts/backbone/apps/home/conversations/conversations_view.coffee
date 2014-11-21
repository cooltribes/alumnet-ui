@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.ConversationView extends Marionette.ItemView
    template: 'home/conversations/templates/conversation'

  class Conversations.MessageView extends Marionette.ItemView
    template: 'home/conversations/templates/message'

  class Conversations.ConversationsView extends Marionette.CompositeView
    template: 'home/conversations/templates/conversations_container'

  class Conversations.MessagesView extends Marionette.CompositeView
    template: 'home/conversations/templates/messages_container'

  class Conversations.Layout extends Marionette.Layout
    template: 'home/conversations/templates/layout'
    regions:
      conversations: '#conversations-region'
      messages: '#messages-region'
