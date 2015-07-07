@AlumNet.module 'EventsApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      events = AlumNet.request('event:entities:open')
      eventsView = new Discover.EventsView
        collection: events
      AlumNet.mainRegion.show(eventsView)
      AlumNet.execute('render:events:submenu',undefined, 1)
      
      
      eventsView.on 'events:search', (term)->        
        console.log term
        #querySearch = { q: name_cont: term }
        @collection.fetch
          data: term
          success: (collection)->
            console.log collection


       
    
      #eventsView.on 'events:search', (querySearch)->
      #  searchedEvents = AlumNet.request('event:entities', querySearch)
      #  console.log querySearch
       

      