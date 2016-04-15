@AlumNet.module 'AdminApp.AttributesList', (AttributesList, @AlumNet, Backbone, Marionette, $, _) ->
  class AttributesList.Layout extends Marionette.LayoutView
    template: 'admin/attributes/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class AttributesList.AttributeView extends Marionette.ItemView
    template: 'admin/attributes/list/templates/category'
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

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

  class AttributesList.AttributesTable extends Marionette.CompositeView
    template: 'admin/attributes/list/templates/attributes_table'
    childView: AttributesList.AttributeView
    childViewContainer: "#attributes-table tbody"