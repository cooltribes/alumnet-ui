@AlumNet.module 'GroupsApp', (GroupsApp, @AlumNet, Backbone, Marionette, $, _) ->
  # GroupsApp.Router = Marionette.AppRouter.extend
  class GroupsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "groups/new": "createGroup"
      "groups/:group_id/posts/:id": "postGroup"
      "groups/:id/posts": "postsGroup"
      "groups/:id/invite": "inviteGroup"
      "groups/:id/about": "aboutGroup"
      "groups/:id/members": "membersGroup"
      "groups/:id/subgroups/new": "createSubGroup"
      "groups/:id/subgroups": "listSubGroups"
      "groups/:id/events/new": "createEvent"
      "groups/:id/events": "listEvents"
      "groups/:id/photos": "listAlbums"
      "groups/:id/files": "listFiles"
      "groups/:id/banner": "bannersList"
      "groups/:id/settings": "settingsEdit"
      "groups/manage": "manageGroups"
      "groups": "discoverGroups"

  API =
    manageGroups: ->
      document.title = 'AlumNet - My groups'
      controller = new GroupsApp.Manage.Controller
      controller.manageGroups()
    discoverGroups: ->
      document.title = 'AlumNet - Discover groups'
      controller = new GroupsApp.Discover.Controller
      controller.discoverGroups()
    createGroup: ->
      document.title = 'AlumNet - Create groups'
      controller = new GroupsApp.Create.Controller
      controller.createGroup()
    postGroup: (group_id, id)->
      controller = new GroupsApp.Posts.Controller
      controller.showPost(group_id, id)
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
    createSubGroup: (id)->
      controller = new GroupsApp.SubGroups.Controller
      controller.createSubGroup(id)
    listSubGroups: (id)->
      controller = new GroupsApp.SubGroups.Controller
      controller.listSubGroups(id)
    createEvent: (id)->
      controller = new GroupsApp.Events.Controller
      controller.createEvent(id)
    listEvents: (id)->
      controller = new GroupsApp.Events.Controller
      controller.listEvents(id)
    listFiles: (id)->
      controller = new GroupsApp.Files.Controller
      controller.listFiles(id)
    inviteEvent: (event, users)->
      controller = new GroupsApp.Events.Controller
      controller.invitations(event, users)
    listAlbums: (id)->
      controller = new GroupsApp.Pictures.Controller
      controller.showAlbums(id)
    bannersList: (id)->
      controller = new GroupsApp.BannerList.Controller
      controller.bannerList(id)
    settingsEdit: (id)->
      controller = new GroupsApp.Settings.Controller
      controller.showSettings(id)

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

  AlumNet.on "groups:subgroups", (id)->
    AlumNet.navigate("groups/#{id}/subgroups")
    API.listSubGroups(id)

  AlumNet.on "groups:discover",  ->
    AlumNet.navigate("groups")
    API.discoverGroups()

  AlumNet.on "group:event:invite", (event, users)->
    API.inviteEvent(event, users)

  AlumNet.on "groups:manage", ->
    AlumNet.navigate("groups/manage")
    API.manageGroups()

  AlumNet.on "group:banner", (id)->
    AlumNet.navigate("groups/#{id}/banner")
    API.bannerList(id)

  AlumNet.addInitializer ->
    new GroupsApp.Router
      controller: API
