@AlumNet.module 'AdminApp.AttributesList', (AttributesList, @AlumNet, Backbone, Marionette, $, _) ->
  class AttributesList.Layout extends Marionette.LayoutView
    template: 'admin/attributes/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class AttributesList.AttributeView extends Marionette.ItemView
    template: 'admin/attributes/list/templates/attribute'
    tagName: "tr"

    modelEvents:
      "change": "modelChange"

    bindings:
      ".js-name": 
        observe: "name"
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
      ".js-mandatory": 
        observe: "mandatory"
        selectOptions:
          collection: [
            value: 0
            label: "No"
          ,
            value: 1
            label: "Yes"
          ,
          ]
      ".js-measure-unit": 
        observe: "measure_unit"
        selectOptions:
          collection: [
            value: "days"
            label: "Days"
          ,
            value: "months"
            label: "Months"
          ,
          ]

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

  class AttributesList.AttributesTable extends Marionette.CompositeView
    template: 'admin/attributes/list/templates/attributes_table'
    childView: AttributesList.AttributeView
    childViewContainer: "#attributes-table tbody"