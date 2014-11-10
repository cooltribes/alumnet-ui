@AlumNet.module 'UserApp', (UserApp, @AlumNet, Backbone, Marionette, $, _) ->
  UserApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "user/posts": "userPosts"
      "friends": "userFriends"

  API =
    userPosts: ->
      controller = new UserApp.Posts.Controller
      controller.showPosts()
    userFriends: ->
      controller = new UserApp.Friends.Controller
      controller.showFriends()


  AlumNet.on "user:posts",  ->
    AlumNet.navigate("user/posts")
    API.showPosts()

  AlumNet.on "user:friends", ->
    AlumNet.navigate("user/friends")
    API.showFriends(id)



  AlumNet.addInitializer ->
    new UserApp.Router
      controller: API
