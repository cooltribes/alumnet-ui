@AlumNet.module 'EventsApp', (EventsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class EventsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "events/:id/about": "aboutEvent"
      "events/:id/posts": "postsEvent"
      "events/:id/attendances": "attendancesEvent"
      "events/:id/photos": "listAlbums"
      "events/:id/payment": "paymentEvent"
      "events/manage": "manageEvents"
      "events/new": "createEvent"
      "events": "discoverEvents"


  API =
    aboutEvent: (id)->
      controller = new EventsApp.About.Controller
      controller.showAbout(id)

    postsEvent: (id)->
      event = AlumNet.request('event:find', id)
      event.on 'find:success', ->
        if event.get('admission_type') == 1 && event.get('attendance_info').status == "going"
          controller = new EventsApp.Payment.Controller
          controller.payEvent(id)
        else
          controller = new EventsApp.Posts.Controller
          controller.showPosts(id)

    attendancesEvent: (id)->
      controller = new EventsApp.Attendances.Controller
      controller.showAttendances(id)

    manageEvents: (id)->
      controller = new EventsApp.Manage.Controller
      controller.manage(AlumNet.current_user.id)

    createEvent: ->
      controller = new EventsApp.Create.Controller
      controller.createEvent(AlumNet.current_user.id)

    paymentEvent: (id)->
      controller = new EventsApp.Payment.Controller
      controller.payEvent(id)

    discoverEvents: ->
      controller = new EventsApp.Discover.Controller
      controller.discover()

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
