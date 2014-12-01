@AlumNet.module 'HomeApp', (HomeApp, @AlumNet, Backbone, Marionette, $, _) ->
  HomeApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "posts": "currentUserPosts"
      "conversations": "currentUserConversations"
      "conversations/:id": "currentUserConversation"


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

  AlumNet.on "home", ->
    AlumNet.navigate("posts")
    API.currentUserPosts()

  AlumNet.on "conversations", ->
    AlumNet.navigate("conversations")
    API.currentUserConversations()

  AlumNet.on "conversation", (conversation_id)->
    AlumNet.navigate("conversations/#{conversation_id}")
    API.currentUserConversation(conversation_id)

  AlumNet.addInitializer ->
    new HomeApp.Router
      controller: API
