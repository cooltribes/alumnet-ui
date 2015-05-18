@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->
  class Package.Controller
    listPackages: ->
      page = new Package.PackagesView
      AlumNet.mainRegion.show(page)
      AlumNet.execute('render:points:submenu',undefined,2,true)

 