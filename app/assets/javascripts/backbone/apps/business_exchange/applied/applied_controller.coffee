@AlumNet.module 'BusinessExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Controller
    applied: ->
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/business_exchanges/applied'

        
      appliedView = new Applied.List
        collection: tasks

      AlumNet.mainRegion.show(appliedView)
      AlumNet.execute('render:business_exchange:submenu', undefined, 0)
