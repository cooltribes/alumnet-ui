@AlumNet.module 'EventsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      events = AlumNet.request('event:entities:open')
      eventsView = new Discover.EventsView
        collection: events
      AlumNet.mainRegion.show(eventsView)
      AlumNet.execute('render:events:submenu',undefined, 1)
      
      ###
      eventsView.on 'search', (term)->        
        querySearch = { q: event_name: term }
        eventsView.collection.fetch
          data: querySearch
          console.log querySearch###
    
      eventsView.on 'events:search', (querySearch)->
        searchedEvents = AlumNet.request('events:entities', querySearch)
        console.log querySearch
    

      