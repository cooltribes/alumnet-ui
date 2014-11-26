@AlumNet.module 'GroupsApp', (GroupsApp, @AlumNet, Backbone, Marionette, $, _) ->
  # GroupsApp.Router = Marionette.AppRouter.extend
  GroupsApp.Router = AlumNet.Routers.Base.extend
    appRoutes:
      "groups/new": "createGroup"
      "groups/:id/posts": "postsGroup"
      "groups/:id/invite": "inviteGroup"
      "groups/:id/about": "aboutGroup"
      "groups/:id/members": "membersGroup"
      "groups": "discoverGroups"

  API =
    discoverGroups: ->
      controller = new GroupsApp.Discover.Controller
      controller.discoverGroups()
    createGroup: ->
      controller = new GroupsApp.Create.Controller
      controller.createGroup()
    postsGroup: (id)->
      controller = new GroupsApp.Posts.Controller
      controller.showPosts(id)
    inviteGroup: (id)->
      controller = new GroupsApp.Invite.Controller
      controller.listUsers(id)
    membersGroup: (id)->
      controller = new GroupsApp.Members.Controller
      controller.listMembers(id)
    aboutGroup: (id)->
      controller = new GroupsApp.About.Controller
      controller.showAbout(id)

  AlumNet.on "groups:create",  ->
    AlumNet.navigate("groups/new")
    API.createGroup()

  AlumNet.on "groups:posts", (id)->
    AlumNet.navigate("groups/#{id}/posts")
    API.postsGroup(id)

  AlumNet.on "groups:invite", (id)->
    AlumNet.navigate("groups/#{id}/invite")
    API.inviteGroup(id)

  AlumNet.on "groups:members", (id)->
    AlumNet.navigate("groups/#{id}/members")
    API.membersGroup(id)

  AlumNet.on "groups:discover",  ->
    AlumNet.navigate("groups")
    API.discoverGroups()

  AlumNet.addInitializer ->
    new GroupsApp.Router
      controller: API
