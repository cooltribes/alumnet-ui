@AlumNet.module 'EventsApp.Manage', (Manage, @AlumNet, Backbone, Marionette, $, _) ->
  class Manage.Controller
    manage: (eventable_id)->
      events = new AlumNet.Entities.EventsCollection null,
        eventable: 'users'
        eventable_id: eventable_id
      eventsView = new Manage.EventsView
        collection: events
      AlumNet.mainRegion.show(eventsView)
      AlumNet.execute('render:events:submenu', undefined, 0)

