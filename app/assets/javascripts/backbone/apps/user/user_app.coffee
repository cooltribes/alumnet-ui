@AlumNet.module 'UserApp', (UserApp, @AlumNet, Backbone, Marionette, $, _) ->
  UserApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "user/posts": "userPosts"


  API =
    userPosts: ->
      controller = new UserApp.Posts.Controller
      controller.showPosts()
    userRequests: ->
      controller = new UserApp.Friends.Controller
      controller.showRequests()


  AlumNet.on "user:posts",  ->
    AlumNet.navigate("user/posts")
    API.showPosts()

  AlumNet.on "user:friends", ->
    AlumNet.navigate("user/friends")
    API.showRequests(id)



  AlumNet.addInitializer ->
    new UserApp.Router
      controller: API
