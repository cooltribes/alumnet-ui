@AlumNet.module 'EventsApp', (EventsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class EventsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "events/:id/about": "aboutEvent"
      "events/:id/posts": "postsEvent"
      "events/:id/attendances": "attendancesEvent"
      "events": "listEvents"


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

  AlumNet.addInitializer ->
    new EventsApp.Router
      controller: API
