@AlumNet.module 'AdminApp.Regions', (Regions, @AlumNet, Backbone, Marionette, $, _) ->
  class Regions.Controller
    regionsList: ->
      regions = AlumNet.request('get:regions')       
      regions.fetch()

      layoutView = new Regions.Layout
      regionsTable = new Regions.RegionsTable
        collection: regions

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(regionsTable)
      AlumNet.execute('render:admin:regions:submenu', undefined, 0, regionsTable)

