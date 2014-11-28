@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.ConversationView extends Marionette.ItemView
    template: 'home/conversations/templates/conversation'
    tagName: 'li'
    triggers:
      'click .js-conversation': 'conversation:clicked'

  class Conversations.MessageView extends Marionette.ItemView
    template: 'home/conversations/templates/message'
    ui:
      'markLink': '.js-mark'
    events:
      'click .unread': 'clickedUnReadLink'
      'click .read': 'clickedReadLink'

    clickedReadLink: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'click:read'

    clickedUnReadLink: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger 'click:unread'

    toggleLink: ->
      if @ui.markLink.hasClass('read')
        @ui.markLink.removeClass('read').addClass('unread').html("Mark as Unread")

      else if @ui.markLink.hasClass('unread')
        @ui.markLink.removeClass('unread').addClass('read').html("Mark as Read")


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
        data.recipients = data.recipients.split(',')
        @trigger 'conversation:submit', data
        @ui.inputSubject.val('')
        @ui.inputBody.val('')
        @ui.selectRecipients.val('')

    onRender: ->
      @ui.selectRecipients.select2
        placeholder: "Select a Friend"
        multiple: true
        minimumInputLength: 2
        ajax:
          url: AlumNet.api_endpoint + '/me/friendships/friends'
          dataType: 'json'
          data: (term)->
            q:
              m: 'or'
              profile_first_name_cont: term
              profile_last_name_cont: term
          results: (data, page) ->
            results:
              data
        formatResult: (data)->
          data.name
        formatSelection: (data)->
          data.name

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

    sumNewMessage: ->
      currentValue = @model.get('unread_messages_count')
      currentValue++
      @model.set('unread_messages_count', currentValue)

    remNewMessage: ->
      currentValue = @model.get('unread_messages_count')
      currentValue--
      @model.set('unread_messages_count', currentValue)

  class Conversations.Layout extends Marionette.LayoutView
    template: 'home/conversations/templates/layout'
    regions:
      conversations: '#conversations-region'
      messages: '#messages-region'
    triggers:
      'click #js-new-conversation': 'new:conversation'

