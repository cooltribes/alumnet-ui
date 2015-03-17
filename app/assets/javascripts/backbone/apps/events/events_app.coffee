@AlumNet.module 'EventsApp', (EventsApp, @AlumNet, Backbone, Marionette, $, _) ->
  class EventsApp.Router extends AlumNet.Routers.Base
    appRoutes:
      "events/:id/about": "aboutEvent"

  API =
    aboutEvent: (id)->
      controller = new EventsApp.About.Controller
      controller.showAbout(id)

  AlumNet.addInitializer ->
    new EventsApp.Router
      controller: API
