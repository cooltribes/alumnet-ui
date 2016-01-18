@AlumNet.module 'HomeApp', (HomeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class HomeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "posts": "currentUserPosts"
      "conversations": "currentUserConversations"
      "conversations/:id": "currentUserConversation"
      "conversations/user/:id": "showUserConversation"
      "notifications": "currentUserNotifications"
      "banner": "currentUserPosts"
      "requests": "currentUserRequests"

  API =
    currentUserPosts: ->
      AlumNet.setTitle('Home')
      controller = new HomeApp.Posts.Controller
      controller.showCurrentUserPosts()
    currentUserConversations: ->
      controller = new HomeApp.Conversations.Controller
      controller.showCurrentUserConversations()
    currentUserConversation: (id) ->
      controller = new HomeApp.Conversations.Controller
      controller.showCurrentUserConversations(id)
    currentUserNotifications: ->
      controller = new HomeApp.Notifications.Controller
      controller.showCurrentUserNotifications()
    conversationWithRecipient: (subject, user)->
      controller = new HomeApp.Conversations.Controller
      controller.showCurrentUserConversations(undefined, subject, user)
    showUserConversation: (id)->
      user = AlumNet.request("user:find", id)
      controller = new HomeApp.Conversations.Controller
      controller.showCurrentUserConversations(undefined, undefined, user)
    currentBanners: ->
      controller = new HomeApp.Posts.Controller
      controller.showCurrentUserPosts(undefined, user)
    currentUserRequests: ->
      controller = new HomeApp.Notifications.Controller
      controller.showCurrentUserRequests()

  AlumNet.on "home", ->
    AlumNet.navigate("posts")
    API.currentUserPosts()

  AlumNet.on "conversations", ->
    AlumNet.navigate("conversations")
    API.currentUserConversations()

  AlumNet.on "conversation", (conversation_id)->
    AlumNet.navigate("conversations/#{conversation_id}")
    API.currentUserConversation(conversation_id)

  AlumNet.on "conversation:recipient", (subject, user)->
    AlumNet.navigate("conversations")
    API.conversationWithRecipient(subject, user)

  AlumNet.on "notifications", ->
    AlumNet.navigate("notifications")
    API.currentUserNotifications()

  AlumNet.on "banner", (user) ->
    AlumNet.navigate("banner")
    API.bannerList()

  AlumNet.on "requests", ->
    AlumNet.navigate("requests")
    API.currentUserRequests()

  AlumNet.addInitializer ->
    new HomeApp.Router
      controller: API
