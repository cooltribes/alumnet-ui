@AlumNet.module 'ChatApp.Chat', (Chat, @AlumNet, Backbone, Marionette, $, _) ->
  class Chat.Layout extends Marionette.LayoutView
    template: 'chat/layout'
    regions:
      usersRegion: '#chat-users-region'
      conversationsRegion: '#chat-conversations-region'
      chatRegion: '#chat-region'

    onBeforeShow: ->
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

      conversationQuery = AlumNet.layerClient.createQuery
        model: layer.Query.Conversation

      conversationsView = new AlumNet.ChatApp.Chat.Conversations
        parentView: @
        data: conversationQuery.data
        collection: new AlumNet.Entities.LayerConversationCollection

      conversationQuery.on 'change', ->
        conversationsView.render()

      @conversationsRegion.show(conversationsView)


  #-----------------------
  #  USERS VIEWS
  #-----------------------

  class Chat.User extends Marionette.ItemView
    template: 'chat/user'
    defaultOptions: ['parentView']

    events:
      'click .user-card': 'createConversation'

    initialize: (options)->
      @parentView = options.parentView


    createConversation: (e)->
      e.preventDefault()
      participants = [@model.id]
      conversation = AlumNet.layerClient.createConversation
        participants: participants
        distinct: true
      @renderConversation(conversation)

    renderConversation: (conversation)->
      messagesQuery = AlumNet.layerClient.createQuery
        model: layer.Query.Message

      messagesQuery.update
        predicate: "conversation.id = '#{conversation.id}'"

      messagesView = new AlumNet.ChatApp.Chat.Messages
        conversation: conversation
        data: messagesQuery.data
        collection: new AlumNet.Entities.LayerMessageCollection

      messagesQuery.on 'change', ->
        messagesView.render()

      @parentView.chatRegion.show(messagesView)

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
  class Chat.Conversation extends Marionette.ItemView
    template: 'chat/conversation'
    defaultOptions: ['parentView']

    events:
      'click .title': 'getConversation'

    initialize: (options)->
      @parentView = options.parentView

    onRender: ->
      @listenTo @, 'add:user', @setTitle
      @getParticipants()

    getParticipants: ->
      self = @
      users = []
      participants = _.without @model.get('participants'), AlumNet.current_user.id
      _.each participants, (participant_id)->
        user = AlumNet.friends.get(participant_id)
        if user
          users.push user
          self.trigger 'add:user', users
        else
          user = AlumNet.request('user:find', participant_id)
          self.listenTo user, 'find:success', (response, options)->
            AlumNet.friends.add(user, {merge: true})
            users.push user
            self.trigger 'add:user', users

    setTitle: (users)->
      names = _.map users, (user)->
        user.get('name')
      @model.set('title', names.join(', '))
      @$('.title').html names.join(', ')

    getConversation: (e)->
      e.preventDefault()
      @renderConversation(@model.get('layerObject'))

    renderConversation: (conversation)->
      messagesQuery = AlumNet.layerClient.createQuery
        model: layer.Query.Message

      messagesQuery.update
        predicate: "conversation.id = '#{conversation.id}'"

      messagesView = new AlumNet.ChatApp.Chat.Messages
        conversation: conversation
        data: messagesQuery.data
        collection: new AlumNet.Entities.LayerMessageCollection

      messagesQuery.on 'change', ->
        messagesView.render()

      @parentView.chatRegion.show(messagesView)

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

    onRender: ->
      @setCollection()

    templateHelpers: ->
      self = @
      conversationCount: @data.length

    setCollection: ->
      self = @
      models = []
      _.each @data, (conversation)->
        model = new AlumNet.FormatLayerData
        model = model.createConversation(conversation)
        models.push model
      @collection.set models



  #-----------------------
  #  MESSAGES VIEWS
  #-----------------------

  class Chat.Message extends Marionette.ItemView
    template: 'chat/message'

    onBeforeRender: ->
      # @getSender()

    templateHelpers: ->
      isCurrentUser: @model.isCurrentUser()

    onShow: ->
      @model.get('layerObject').isRead = true

    getSender: ->
      sender_id = @model.get('sender').id
      if @model.isCurrentUser()
        user = AlumNet.current_user
      else
        user = AlumNet.friends.get(participant_id)

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
      console.log @conversation

    onRender: ->
      @setCollection()
      container = @$('.messagesContainer')
      container.scrollTop(container.prop('scrollHeight'))

    CheckKey: (e)->
      textarea = $(e.currentTarget)
      if e.keyCode != 13 || !textarea.val()
        return
      @sendMessage(@conversation, textarea.val())
      textarea.val("").focus()

    setCollection: ->
      self = @
      models = []
      _.each @data.concat().reverse(), (message)->
        model = new AlumNet.FormatLayerData
        model = model.createMessage(message)
        models.push model
      @collection.set models

    sendMessage: (conversation, text)->
      if conversation
        message = conversation.createMessage(text).send()
        message.on 'messages:sent', (e)->
          AlumNet.log "message sent: #{e.target.parts[0].body}"
