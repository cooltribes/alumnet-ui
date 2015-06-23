@AlumNet.module 'BusinessExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      tasks = new AlumNet.Entities.BusinessExchangeCollection
      tasks.fetch()
      discoverView = new Discover.List
        collection: tasks

      AlumNet.mainRegion.show(discoverView)
      AlumNet.execute('render:business_exchange:submenu', undefined, 3)
