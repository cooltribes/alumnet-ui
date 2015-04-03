@AlumNet.module 'EventsApp', (EventsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class EventsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "events/:id/about": "aboutEvent"
      "events/:id/posts": "postsEvent"
      "events/:id/attendances": "attendancesEvent"
      "events/:id/photos": "listAlbums"      
      "events": "listEvents"
      "events/new": "createEvent"


  API =
    aboutEvent: (id)->
      controller = new EventsApp.About.Controller
      controller.showAbout(id)

    postsEvent: (id)->
      controller = new EventsApp.Posts.Controller
      controller.showPosts(id)

    attendancesEvent: (id)->
      controller = new EventsApp.Attendances.Controller
      controller.showAttendances(id)

    listEvents: (id)->
      controller = new EventsApp.List.Controller
      controller.list(AlumNet.current_user.id)

    createEvent: ->
      controller = new EventsApp.Create.Controller
      controller.createEvent(AlumNet.current_user.id)

    inviteEvent: (event, users)->
      controller = new EventsApp.Create.Controller
      controller.invitations(event, users)

    listAlbums: (id)->
      controller = new EventsApp.Pictures.Controller
      controller.showAlbums(id)  

  AlumNet.on "user:event:invite", (event, users)->
    API.inviteEvent(event, users)

  AlumNet.addInitializer ->
    new EventsApp.Router
      controller: API
