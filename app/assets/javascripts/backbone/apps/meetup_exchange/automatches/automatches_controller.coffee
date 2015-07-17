@AlumNet.module 'MeetupExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Controller
    automatches: ->
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/automatches'
      automatchesView = new AutoMatches.List
        collection: tasks

      AlumNet.mainRegion.show(automatchesView)
      AlumNet.execute('render:meetup_exchange:submenu', undefined, 4)
