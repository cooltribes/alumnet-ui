@AlumNet.module 'AdminApp', (AdminApp, @AlumNet, Backbone, Marionette, $, _) ->
  # AdminApp.Router = Marionette.AppRouter.extend
  class AdminApp.Router extends AlumNet.Routers.Admin
    appRoutes:
      # "groups/new": "createGroup"
      # "groups/:id/posts": "postsGroup"
      # "groups/:id/invite": "inviteGroup"
      # "groups/:id/about": "aboutGroup"
      # "groups/:id/members": "membersGroup"
      # "groups/:id/subgroups/new": "createSubGroup"
      "admin/users": "manageUsers"
      # "groups": "discoverGroups"

  API =
    manageUsers: ->
      controller = new AdminApp.Users.Controller
      controller.manageUsers()
    # postsGroup: (id)->
    #   controller = new AdminApp.Posts.Controller
    #   controller.showPosts(id)
   
  AlumNet.on "groups:create",  ->
    AlumNet.navigate("groups/new")
    API.createGroup()

  AlumNet.on "groups:posts", (id)->
    AlumNet.navigate("groups/#{id}/posts")
    API.postsGroup(id)

  AlumNet.addInitializer ->
    new AdminApp.Router
      controller: API
