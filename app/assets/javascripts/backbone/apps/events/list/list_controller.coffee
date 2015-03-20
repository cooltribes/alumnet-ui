@AlumNet.module 'EventsApp.List', (List, @AlumNet, Backbone, Marionette, $, _) ->
  class List.Controller
    list: (eventable_id)->
      events = AlumNet.request('event:entities', 'users', eventable_id)
      events.getUpcoming()
      eventsView = new List.EventsView
        collection: events
      AlumNet.mainRegion.show(eventsView)
      AlumNet.execute('render:events:submenu')

