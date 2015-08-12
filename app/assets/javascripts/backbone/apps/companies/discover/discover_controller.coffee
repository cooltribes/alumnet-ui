@AlumNet.module 'CompaniesApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      companies = new AlumNet.Entities.CompaniesCollection
      companies.fetch()
      discoverView = new Discover.List
        collection: companies

      AlumNet.mainRegion.show(discoverView)
      AlumNet.execute('render:companies:submenu', undefined, 3)
