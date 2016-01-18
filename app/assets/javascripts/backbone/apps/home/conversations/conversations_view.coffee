@AlumNet.module 'HomeApp.Conversations', (Conversations, @AlumNet, Backbone, Marionette, $, _) ->
  class Conversations.ConversationView extends Marionette.ItemView
    template: 'home/conversations/templates/conversation'
    tagName: 'li'
    triggers:
      'click .js-conversation': 'conversation:clicked'

    ui:
      'messagesBadge': '.messageCard__badge'

    initialize: ->
      @listenTo(AlumNet.current_user, 'change:unread_messages_count', @updateMessagesCountBadge)
      AlumNet.setTitle('Conversations')

    updateMessagesCountBadge: ->
      view = @
      @model.fetch
        success: (model)->
          value = model.get('unread_messages_count')
          view.ui.messagesBadge.html(value)
          if value > 0
            view.ui.messagesBadge.show()
          else
            view.ui.messagesBadge.hide()
          AlumNet.setTitle('Conversations')


  class Conversations.MessageView extends Marionette.ItemView
    template: 'home/conversations/templates/message'
    
    initialize: (options)->
      view = @
      @on 'click:unread': ->
        Backbone.ajax
          url: AlumNet.api_endpoint + '/me/conversations/' + @model.get('conversation_id') + '/receipts/' + @model.id + '/unread'
          method: 'PUT'
          success: ->
            view.toggleLink()
            AlumNet.current_user.trigger 'change:unread_messages_count'

      @on 'click:read': ->
        Backbone.ajax
          url: AlumNet.api_endpoint + '/me/conversations/' + @model.get('conversation_id') + '/receipts/' + @model.id + '/read'
          method: 'PUT'
          success: ->
            view.toggleLink()
            AlumNet.current_user.trigger 'change:unread_messages_count'

    ui:
      'markLink': '.js-mark'
      'mensaje':'#js-mensaje'
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

    onRender: ->
      view = this
      @ui.mensaje.linkify()

  class Conversations.ConversationsView extends Marionette.CollectionView
    template: 'home/conversations/templates/conversations_container'
    childView: Conversations.ConversationView
    tagName: 'ul'
    className: 'conversations-container list-unstyled'

    initialize: (options)->
      @layout = options.layout
      view = @
      @on 'childview:conversation:clicked', (childView)->
        conversation = childView.model
        view.layout.renderReplyConversation(conversation)


    onRender: ->
      $('body,html').animate({scrollTop: 0}, 600);


  class Conversations.NewConversationView extends Marionette.CompositeView
    template: 'home/conversations/templates/new_conversation'
    childView: Conversations.MessageView
    initialize: (options) ->
      @recipient = options.recipient
      @subject = options.subject
      @layout = options.layout

    templateHelpers: ->
      recipient: if @recipient then @recipient.id else ''
      subject: if @subject then @subject else ''

    ui:
      'inputBody': '#body'
      'inputSubject': '#subject'
      'selectRecipients': '#recipients'

    events:
      'click .js-submit':'clickedSubmit'

    clickedSubmit: (e)->
      view = @
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != '' && data.recipients != ''
        data.recipients = data.recipients.split(',')
        conversation = AlumNet.request('conversations:new')
        conversation.save data,
          success: (model, response, options) ->
            view.layout.conversations.add(model, at: 0)
            # messages = model.messages
            view.ui.inputSubject.val('')
            view.ui.inputBody.val('')
            view.ui.selectRecipients.select2('val', '')

    onRender: ->
      if @recipient
        user_data = { id: @recipient.id, name: @recipient.get('name') }
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
        initSelection: (element, callback)->
          callback(user_data) if user_data

  class Conversations.ReplyView extends Marionette.CompositeView
    template: 'home/conversations/templates/reply'
    childView: Conversations.MessageView
    childViewContainer: '.messages-container'

    initialize: (options)->
      @layout = options.layout
      @collection = @model.messages
      @collection.fetch
        success: (collection)->
          collection.each (message)->
            if not message.get('is_read')
              Backbone.ajax
                url: AlumNet.api_endpoint + '/me/conversations/' + message.get('conversation_id') + '/receipts/' + message.id + '/read'
                method: 'PUT'
          AlumNet.current_user.trigger 'change:unread_messages_count'

    ui:
      'inputBody': '#body'

    events:
      'click .js-submit':'clickedSubmit'

    clickedSubmit: (e)->
      view = @
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      if data.body != ''
        message = AlumNet.request('messages:new', @model.id)
        message.save data,
          success: (model, response, options) ->
            view.collection.add(model)
            view.render()

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
      conversations_section: '#conversations-region'
      messages_section: '#messages-region'

    initialize: (options)->
      AlumNet.setTitle('Conversations')
      @conversation_id = options.conversation_id
      @subject = options.subject
      @user = options.user

    events:
      'click #js-new-conversation': 'newCoversation'

    onShow: ->
      layout = @
      # Load and show conversations section
      @conversations = AlumNet.request('conversations:get', {})
      conversationsView = new Conversations.ConversationsView
        collection: @conversations
        layout: layout
      @conversations_section.show(conversationsView)

      # Set current_conversation
      @conversations.on 'fetch:success', ->
        current_conversation = layout.conversations.get(layout.conversation_id)
        if current_conversation
          layout.renderReplyConversation(current_conversation)
        else
          layout.renderNewConversation()

    renderNewConversation: ->
      newConversationView = new Conversations.NewConversationView
        recipient: @user
        subject: @subject
        layout: @
      @messages_section.show(newConversationView)

    renderReplyConversation: (conversation)->
      replyView = new Conversations.ReplyView
        model: conversation
        layout: @
      @messages_section.show(replyView)

    newCoversation: (e)->
      e.preventDefault()
      @user = null
      @subject = null
      @renderNewConversation()

