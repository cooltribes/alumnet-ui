@AlumNet.module 'EventsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      events = new AlumNet.Entities.EventsCollection
      eventsView = new Discover.EventsView
        collection: events
      AlumNet.mainRegion.show(eventsView)
      AlumNet.execute('render:events:submenu', undefined, 1)