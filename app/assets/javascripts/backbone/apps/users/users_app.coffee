@AlumNet.module 'UsersApp', (UsersApp, @AlumNet, Backbone, Marionette, $, _) ->
  # UsersApp.Router = Marionette.AppRouter.extend
  class UsersApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "users/:id/posts": "userPosts"
      "users/:id/about": "userAbout"

  API =
    userPosts: (id)->
      controller = new UsersApp.Posts.Controller
      controller.showPosts(id)

    userAbout: (id)->
      controller = new UsersApp.About.Controller
      controller.showAbout(id)

  AlumNet.on "user:posts", (user_id) ->
    AlumNet.navigate("user/#{user_id}/posts")
    API.showPosts(user_id)

  AlumNet.addInitializer ->
    new UsersApp.Router
      controller: API
