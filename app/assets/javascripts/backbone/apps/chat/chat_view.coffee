@AlumNet.module 'ChatApp.Chat', (Chat, @AlumNet, Backbone, Marionette, $, _) ->
  class Chat.Layout extends Marionette.LayoutView
    template: 'chat/layout'
    regions:
      messagesRegion: '#messages-region'
      usersRegion: '#users-region'
      conversationsRegion: '#conversations-region'

    events:
      'click .js-action': 'renderContent'
      'click #js-chat-reduce': 'reduceContent'

    renderContent: (e)->
      e.preventDefault()
      action = $(e.currentTarget).data('action')
      @showRegion(action)

    templateHelpers: ->
      name: AlumNet.current_user.get("name")

    showRegion: (region)->
      self = @
      names = ['users', 'conversations', 'messages']
      _.each names, (name)->
        self.$("##{name}-region").hide()
      @$("##{region}-region").show()

    onBeforeShow: ->
      @showFriends()
      @showConversations()

    showFriends: ->
      self = @
      friends = AlumNet.request('current_user:friendships:friends')
      friendsView = new AlumNet.ChatApp.Chat.Users
        collection: friends
        parentView: @

      promise = friends.fetch()
      promise.done (results)->
        ##This store the friends to return when is required by conversation or message
        AlumNet.friends.set(friends.models, {remove: false})
        self.usersRegion.show(friendsView)

    showConversations: ->
      conversationQuery = AlumNet.layerClient.createQuery
        model: layer.Query.Conversation

      conversationCollection = new AlumNet.Entities.LayerConversationCollection

      conversationsView = new AlumNet.ChatApp.Chat.Conversations
        parentView: @
        data: conversationQuery.data
        collection: conversationCollection

      @listenTo conversationQuery, 'change', (evt)->
        if evt.type == 'data'
          models = []
          _.each evt.data, (conversation)->
            model = new AlumNet.FormatLayerData('conversation', conversation)
            models.push model
          conversationCollection.set models

        if evt.type == 'insert' || evt.type == 'property'
          model = new AlumNet.FormatLayerData('conversation', evt.target)
          conversationCollection.add(model, {merge: true})

      @conversationsRegion.show(conversationsView)

    setUnreadCount: (count)->
      if count > 0
        console.log count

    reduceContent: (e)->
      e.preventDefault()
      @$('#chat').toggleClass('chatReduce')

  #-----------------------
  #  SHARE VIEW
  #-----------------------

  class Chat.RenderConversation extends Marionette.ItemView

    renderConversation: (conversation)->
      # if @checkViewConversation(conversation)
      messagesQuery = AlumNet.layerClient.createQuery
        model: layer.Query.Message

      messagesQuery.update
        predicate: "conversation.id = '#{conversation.id}'"

      messageCollection = new AlumNet.Entities.LayerMessageCollection

      messagesView = new AlumNet.ChatApp.Chat.Messages
        conversation: conversation
        data: messagesQuery.data
        collection: messageCollection

      @listenTo messagesQuery, 'change', (evt)->
        if evt.type == 'data'
          models = []
          _.each evt.data.concat().reverse(), (message)->
            model = new AlumNet.FormatLayerData('message', message)
            models.push model
          messageCollection.set models
        if evt.type == 'insert'
            model = new AlumNet.FormatLayerData('message', evt.target)
            messageCollection.add(model, {merge: true})

      @listenTo AlumNet.layerClient, 'typing-indicator-change', (evt)->
        if evt.conversationId == conversation.id
          messagesView.trigger 'typing', evt.typing[0]
          messagesView.trigger 'paused', evt.paused[0]

      @parentView.messagesRegion.show(messagesView)
      @parentView.showRegion('messages')

    checkViewConversation: (conversation)->
      view = @parentView.messagesRegion.currentView
      if view && view.conversation.id == conversation.id
        false
      else
        true


  #-----------------------
  #  USERS VIEWS
  #-----------------------

  class Chat.User extends Chat.RenderConversation
    template: 'chat/user'
    defaultOptions: ['parentView']

    events:
      'click .user-card': 'createConversation'

    initialize: (options)->
      @parentView = options.parentView
      @listenTo @model, 'change', @render

    createConversation: (e)->
      e.preventDefault()
      participants = ["#{@model.id}"]
      conversation = AlumNet.layerClient.createConversation
        participants: participants
        distinct: true
      @renderConversation(conversation)


  class Chat.Users extends Marionette.CompositeView
    template: 'chat/users'
    childView: AlumNet.ChatApp.Chat.User
    childViewContainer: '.friendsContainer'
    childViewOptions: ->
      parentView: @parentView
    defaultOptions: ['parentView']

    initialize: (options)->
      @parentView = options.parentView



  #-----------------------
  #  COVERSATIONS VIEWS
  #-----------------------
  class Chat.Conversation extends Chat.RenderConversation
    template: 'chat/conversation'
    defaultOptions: ['parentView']

    events:
      'click #js-conversation': 'getConversation'

    initialize: (options)->
      @parentView = options.parentView
      @listenTo @model, 'change', @render

    onRender: ->
      @listenTo @, 'add:user', @updateConversation
      @getParticipants()

    getParticipants: ->
      self = @
      users = []
      participants = _.without @model.get('participant_ids'), "#{AlumNet.current_user.id}"
      _.each participants, (participant_id)->
        id = parseInt(participant_id)
        user = AlumNet.friends.get(id)
        if user
          users.push user
          self.trigger 'add:user', users
        else
          user = AlumNet.request('user:find', id)
          self.listenTo user, 'find:success', (response, options)->
            AlumNet.friends.add(user, {merge: true})
            users.push user
            self.trigger 'add:user', users

    updateConversation: (users)->
      names = _.map users, (user)->
        user.get('name')

      avatars = _.map users, (user)->
        user.get('avatar').medium

      @model.set('title', names.join(', '))
      @model.set('participants', users)

      @$('.title').html names.join(', ')
      @$('.image').attr src: avatars

    getConversation: (e)->
      e.preventDefault()
      @renderConversation(@model.get('layerObject'))


  class Chat.Conversations extends Marionette.CompositeView
    template: 'chat/conversations'
    childView: AlumNet.ChatApp.Chat.Conversation
    childViewContainer: '.conversationsContainer'
    childViewOptions: ->
      parentView: @parentView
    defaultOptions: ['parentView', 'data']

    initialize: (options)->
      @parentView = options.parentView
      @data = options.data

    templateHelpers: ->
      conversationCount: @collection.length


  #-----------------------
  #  MESSAGES VIEWS
  #-----------------------

  class Chat.Message extends Marionette.ItemView
    template: 'chat/message'

    onBeforeRender: ->
      @getSender()

    templateHelpers: ->
      isCurrentUser: @model.isCurrentUser()

    onShow: ->
      if @model.get('sender').id == AlumNet.current_user.id
        @$('#body').attr class: 'bubble blue'
      @model.get('layerObject').isRead = true
      container = $('.messagesContainer')
      container.scrollTop(container.prop('scrollHeight'))

    getSender: ->
      sender_id = @model.get('sender').id
      sender_id = parseInt(sender_id)
      if sender_id == AlumNet.current_user.id
        user = AlumNet.current_user
      else
        user = AlumNet.friends.get(sender_id)

      if user
        userInfo = { id: sender_id, fullname: user.get('name'), avatar_url: user.get('avatar').large }
        @model.set('sender', userInfo)

  class Chat.Messages extends Marionette.CompositeView
    template: 'chat/messages'
    childView: AlumNet.ChatApp.Chat.Message
    childViewContainer: '.messagesContainer'
    defaultOptions: ['conversation', 'data']

    events: ->
      'keypress #chat-message': 'CheckKey'

    initialize: (options)->
      @conversation = options.conversation
      @data = options.data

    onShow: ->
      typing = AlumNet.layerClient.createTypingListener(document.getElementById('chat-message'))
      typing.setConversation(@conversation)

      @listenTo @, 'typing', (userId)->
        id = parseInt(userId)
        user = AlumNet.friends.get(id)
        if user
          text = "#{user.get('name')} is typing..."
          @$('#js-typing').html(text)
        else
          @$('#js-typing').html('')

      @listenTo @, 'paused', (userId)->
        if userId
          @$('#js-typing').html('')

    CheckKey: (e)->
      textarea = $(e.currentTarget)
      if e.keyCode != 13 || !textarea.val()
        return
      @sendMessage(@conversation, textarea.val())
      textarea.val("").focus()

    sendMessage: (conversation, text)->
      if conversation
        message = conversation.createMessage(text).send()
        # message.on 'messages:sent', (e)->
        #   AlumNet.log "message sent: #{e.target.parts[0].body}"