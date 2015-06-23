@AlumNet.module 'EventsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      events = AlumNet.request('event:entities:open')
      eventsView = new Discover.EventsView
        collection: events
      AlumNet.mainRegion.show(eventsView)
      AlumNet.execute('render:events:submenu',undefined, 1)
      
      
      eventsView.on 'search', (term)->        
        querySearch = { q: name_cont: term }
        eventsView.collection.fetch
          data: querySearch

       
    
      #eventsView.on 'events:search', (querySearch)->
      #  searchedEvents = AlumNet.request('event:entities', querySearch)
      #  console.log querySearch
       

      