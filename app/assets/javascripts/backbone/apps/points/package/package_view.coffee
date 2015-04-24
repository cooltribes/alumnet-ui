@AlumNet.module 'PointsApp.Package', (Package, @AlumNet, Backbone, Marionette, $, _) ->

  class Package.PackagesView extends Marionette.ItemView
    template: 'points/package/templates/packages_list'