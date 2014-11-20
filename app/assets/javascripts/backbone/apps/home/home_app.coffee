@AlumNet.module 'HomeApp', (HomeApp, @AlumNet, Backbone, Marionette, $, _) ->
  HomeApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "posts": "currentUserPosts"

  API =
    currentUserPosts: ->
      controller = new HomeApp.Posts.Controller
      controller.showCurrentUserPosts()

  AlumNet.on "home", ->
    AlumNet.navigate("post")
    API.currentUserPosts()

  AlumNet.addInitializer ->
    new HomeApp.Router
      controller: API
