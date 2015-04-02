@AlumNet.module 'UsersApp', (UsersApp, @AlumNet, Backbone, Marionette, $, _) ->

  class UsersApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "users/:id/posts": "userPosts"
      "users/:id/about": "userAbout"
      "users/:id/friends": "userFriends"
      "users/:id/photos": "userPictures"
      "users/:id/events": "userEvents"



  API =
    userPosts: (id)->
      controller = new UsersApp.Posts.Controller
      controller.showPosts(id)

    userAbout: (id)->
      controller = new UsersApp.About.Controller
      controller.showAbout(id)

    userFriends: (id)->
      controller = new UsersApp.Friends.Controller
      #If I am watching my own profile
      if AlumNet.current_user.get("id") == parseInt(id)
        controller.showMyLayout()
      else
        controller.showUserLayout(id)

    userPictures: (id)->
      controller = new UsersApp.Pictures.Controller
      controller.showAlbums(id)

    userEvents: (id)->
      controller = new UsersApp.Events.Controller
      controller.showEvents(id)


  AlumNet.on "user:posts", (user_id) ->
    AlumNet.navigate("user/#{user_id}/posts")
    API.userPosts(user_id)

  AlumNet.on "user:about", (user_id) ->
    AlumNet.navigate("user/#{user_id}/about")
    API.userAbout(user_id)

  AlumNet.addInitializer ->
    new UsersApp.Router
      controller: API
