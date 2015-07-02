@AlumNet.module 'BusinessExchangeApp.AutoMatches', (AutoMatches, @AlumNet, Backbone, Marionette, $, _) ->
  class AutoMatches.Controller
    automatches: ->
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/business_exchanges/automatches'
      automatchesView = new AutoMatches.List
        collection: tasks

      AlumNet.mainRegion.show(automatchesView)
      AlumNet.execute('render:business_exchange:submenu', undefined, 4)