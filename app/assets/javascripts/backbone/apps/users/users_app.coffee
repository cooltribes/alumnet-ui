@AlumNet.module 'UsersApp', (UsersApp, @AlumNet, Backbone, Marionette, $, _) ->

  class UsersApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "profile": "userProfile"
      "users/:user_id/posts/:id": "userPost"
      "users/:id/posts": "userPosts"
      "users/:id/about": "userAbout"
      "users/:id/friends": "userFriends"
      "users/:id/photos": "userPictures"
      "users/:id/events": "userEvents"
      "users/:id/business-exchange": "userBusiness"
      "users/:id/profile": "publicProfile"

  API =
    userPost: (user_id, id)->
      @registerVisit(user_id)
      controller = new UsersApp.Posts.Controller
      controller.showPost(user_id, id)

    userPosts: (id)->
      @registerVisit(id)
      controller = new UsersApp.Posts.Controller
      controller.showPosts(id)

    userProfile: ->
      controller = new UsersApp.About.Controller
      controller.showAbout(AlumNet.current_user.id)

    userAbout: (id)->
      @registerVisit(id)
      controller = new UsersApp.About.Controller
      controller.showAbout(id)

    publicProfile: (id)->
      @registerVisit(id)
      controller = new UsersApp.About.Controller
      controller.showProfile(id)

    userFriends: (id)->
      controller = new UsersApp.Friends.Controller
      #If I am watching my own profile
      if AlumNet.current_user.get("id") == parseInt(id)
        controller.showMyLayout()
      else
        @registerVisit(id)
        controller.showUserLayout(id)

    userPictures: (id)->
      @registerVisit(id)
      controller = new UsersApp.Pictures.Controller
      controller.showAlbums(id)

    userEvents: (id)->
      @registerVisit(id)
      controller = new UsersApp.Events.Controller
      controller.showEvents(id)

    userBusiness: (id)->
      @registerVisit(id)
      controller = new UsersApp.Business.Controller
      controller.showBusiness(id)

    registerVisit: (id)->
      Backbone.ajax
        method: 'POST'
        url: AlumNet.api_endpoint + "/users/#{id}/register_visit"


  AlumNet.on "user:posts", (user_id) ->
    AlumNet.navigate("user/#{user_id}/posts")
    API.userPosts(user_id)

  AlumNet.on "user:about", (user_id) ->
    AlumNet.navigate("user/#{user_id}/about")
    API.userAbout(user_id)

  AlumNet.addInitializer ->
    new UsersApp.Router
      controller: API
