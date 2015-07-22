@AlumNet.module 'AdminApp.FeaturesList', (FeaturesList, @AlumNet, Backbone, Marionette, $, _) ->
  class FeaturesList.Layout extends Marionette.LayoutView
    template: 'admin/features/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class FeaturesList.FeatureView extends Marionette.ItemView
    template: 'admin/features/list/templates/feature'
    tagName: "tr"

    modelEvents:
      "change": "modelChange"

    initialize: ()->
      #view.$("[name=status]")
      #@listenTo(@model, 'render:view', @renderView)

    bindings:
      ".js-name": 
        observe: "name"
        events: ['blur']
      ".js-description": 
        observe: "description"
        events: ['blur']
      ".js-status": 
        observe: "status"
        selectOptions:
          collection: [
            value: "inactive"
            label: "inactive"
          ,
            value: "active"
            label: "active"
          ,
          ]

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

  class FeaturesList.FeaturesTable extends Marionette.CompositeView
    template: 'admin/features/list/templates/features_table'
    childView: FeaturesList.FeatureView
    childViewContainer: "#features-table tbody"