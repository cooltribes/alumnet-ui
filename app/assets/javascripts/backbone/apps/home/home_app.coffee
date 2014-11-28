@AlumNet.module 'HomeApp', (HomeApp, @AlumNet, Backbone, Marionette, $, _) ->
  # HomeApp.Router = Marionette.AppRouter.extend
  class HomeApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "posts": "currentUserPosts"
      "conversations": "currentUserConversations"

  API =
    currentUserPosts: ->
      controller = new HomeApp.Posts.Controller
      controller.showCurrentUserPosts()
    currentUserConversations: ->
      controller = new HomeApp.Conversations.Controller
      controller.showCurrentUserConversations()

  AlumNet.on "home", ->
    AlumNet.navigate("posts")
    API.currentUserPosts()

  AlumNet.on "conversations", ->
    AlumNet.navigate("conversations")
    API.currentUserConversations()

  AlumNet.addInitializer ->
    new HomeApp.Router
      controller: API
