@AlumNet.module 'EventsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      events = AlumNet.request('event:entities:open')
      eventsView = new Discover.EventsView
        collection: events
      AlumNet.mainRegion.show(eventsView)
      AlumNet.execute('render:events:submenu')

