@AlumNet.module 'MeetupExchangeApp.Applied', (Applied, @AlumNet, Backbone, Marionette, $, _) ->
  class Applied.Controller
    applied: ->
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/meetup_exchanges/applied'
      appliedView = new Applied.List
        collection: tasks

      AlumNet.mainRegion.show(appliedView)
      #AlumNet.execute('render:meetup_exchange:submenu', undefined, 0)
