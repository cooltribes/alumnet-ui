@AlumNet.module 'AdminApp.FeaturesList', (FeaturesList, @AlumNet, Backbone, Marionette, $, _) ->
  class FeaturesList.Controller
    featuresList: ->
      features = AlumNet.request('feature:entities', {})
      layoutView = new FeaturesList.Layout
      featuresTable = new FeaturesList.FeaturesTable
         collection: features

      AlumNet.mainRegion.show(layoutView)
      layoutView.table.show(featuresTable)