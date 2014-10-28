@AlumNet.module 'GroupsApp', (GroupsApp, @AlumNet, Backbone, Marionette, $, _) ->
  GroupsApp.Router = Marionette.AppRouter.extend
    appRoutes:
      "groups/new": "createGroup"
      "groups/:id/invite": "inviteGroup"
      "groups/:id/about": "aboutGroup"
      "groups": "discoverGroups"

  API =
    discoverGroups: ->
      controller = new GroupsApp.Discover.Controller
      controller.discoverGroups()
    createGroup: ->
      controller = new GroupsApp.Create.Controller
      controller.createGroup()
    inviteGroup: (id)->
      controller = new GroupsApp.Invite.Controller
      controller.listUsers(id)
    aboutGroup: (id)->
      controller = new GroupsApp.About.Controller
      controller.showAbout(id)

  AlumNet.on "groups:create",  ->
    AlumNet.navigate("groups/new")
    API.createGroup()

  AlumNet.on "groups:invite", (id)->
    AlumNet.navigate("groups/#{id}/invite")
    API.inviteGroup(id)

  AlumNet.on "groups:discover",  ->
    AlumNet.navigate("groups")
    API.discoverGroups()

  AlumNet.on "groups:about", (layout)->
    API.aboutGroup(layout)

  AlumNet.addInitializer ->
    new GroupsApp.Router
      controller: API
