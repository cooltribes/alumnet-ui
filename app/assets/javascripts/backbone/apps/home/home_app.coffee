@AlumNet.module 'HomeApp', (HomeApp, @AlumNet, Backbone, Marionette, $, _) ->
  class HomeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "posts": "currentUserPosts"
      "conversations": "currentUserConversations"
      "conversations/:id": "currentUserConversation"
      "notifications": "currentUserNotifications"

  API =
    currentUserPosts: ->
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

  AlumNet.on "home", ->
    AlumNet.navigate("posts")
    API.currentUserPosts()

  AlumNet.on "conversations", ->
    AlumNet.navigate("conversations")
    API.currentUserConversations()

  AlumNet.on "conversation", (conversation_id)->
    AlumNet.navigate("conversations/#{conversation_id}")
    API.currentUserConversation(conversation_id)

  AlumNet.on "notifications", ->
    AlumNet.navigate("notifications")
    API.currentUserNotifications()

  AlumNet.addInitializer ->
    new HomeApp.Router
      controller: API
