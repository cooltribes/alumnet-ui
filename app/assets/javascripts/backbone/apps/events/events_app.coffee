@AlumNet.module 'EventsApp', (EventsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class EventsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "events/:id/about": "aboutEvent"
      "events/:event_id/posts/:id": "postEvent"
      "events/:id/posts": "postsEvent"
      "events/:id/attendances": "attendancesEvent"
      "events/:id/photos": "listAlbums"
      "events/:id/payment": "paymentEvent"
      "events/:id/files": "showFiles"
      "events/manage": "manageEvents"
      "events/new": "createEvent"
      "events": "discoverEvents"
      "events/prueba": "showEvents"

  API =
    aboutEvent: (id)->
      controller = new EventsApp.About.Controller
      controller.showAbout(id)

    postEvent: (event_id, id)->
      controller = new EventsApp.Posts.Controller
      controller.showPost(event_id, id)

    postsEvent: (id)->
      controller = new EventsApp.Posts.Controller
      controller.showPosts(id)

    attendancesEvent: (id)->
      controller = new EventsApp.Attendances.Controller
      controller.showAttendances(id)

    manageEvents: (id)->
      AlumNet.setTitle('Manage Events')
      controller = new EventsApp.Manage.Controller
      controller.manage(AlumNet.current_user.id)

    createEvent: ->
      AlumNet.setTitle('Create Event')
      controller = new EventsApp.Create.Controller
      controller.createEvent(AlumNet.current_user.id)

    paymentEvent: (id)->
      controller = new EventsApp.Payment.Controller
      controller.payEvent(id)

    showFiles: (id)->
      controller = new EventsApp.Files.Controller
      controller.showFiles(id)

    discoverEvents: ->
      AlumNet.setTitle('Discover Events')
      controller = new EventsApp.Discover.Controller
      controller.discover()

    inviteEvent: (event, users)->
      controller = new EventsApp.Create.Controller
      controller.invitations(event, users)

    listAlbums: (id)->
      controller = new EventsApp.Pictures.Controller
      controller.showAlbums(id)

    showEvents: ()->
      controller = new EventsApp.Main.Controller
      controller.showMainEvents("prueba")

  AlumNet.on "user:event:invite", (event, users)->
    API.inviteEvent(event, users)

  AlumNet.on "events:discover", ->
    AlumNet.navigate("events")
    API.discoverEvents()

  AlumNet.addInitializer ->
    new EventsApp.Router
      controller: API
