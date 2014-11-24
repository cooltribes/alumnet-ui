@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.ConversationView extends Marionette.ItemView
    template: 'home/conversations/templates/conversation'
    tagName: 'li'
    triggers:
      'click .js-conversation': 'conversation:clicked'

  class Conversations.MessageView extends Marionette.ItemView
    template: 'home/conversations/templates/message'

  class Conversations.ConversationsView extends Marionette.CollectionView
    template: 'home/conversations/templates/conversations_container'
    childView: Conversations.ConversationView
    tagName: 'ul'
    className: 'conversations-container'

  class Conversations.NewConversationView extends Marionette.CompositeView
    template: 'home/conversations/templates/new_conversation'
    childView: Conversations.MessageView
    ui:
      'inputBody': '#body'
      'inputSubject': '#subject'
      'selectRecipients': '#recipients'
    events:
      'click .js-submit':'clickedSubmit'

    clickedSubmit: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != '' && data.recipients != ''
        @trigger 'conversation:submit', data
        @ui.inputSubject.val('')
        @ui.inputBody.val('')
        @ui.selectRecipients.val('')


  class Conversations.ReplyView extends Marionette.CompositeView
    template: 'home/conversations/templates/reply'
    childView: Conversations.MessageView
    childViewContainer: '.messages-container'
    ui:
      'inputBody': '#body'

    events:
      'click .js-submit':'clickedSubmit'

    clickedSubmit: (e)->
      e.stopPropagation()
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != ''
        @trigger 'reply:submit', data
        @ui.inputBody.val('')


  class Conversations.Layout extends Marionette.LayoutView
    template: 'home/conversations/templates/layout'
    regions:
      conversations: '#conversations-region'
      messages: '#messages-region'
    triggers:
      'click #js-new-conversation': 'new:conversation'

