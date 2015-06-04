@AlumNet.module 'AdminApp.ActionsList', (ActionsList, @AlumNet, Backbone, Marionette, $, _) ->
  class ActionsList.Layout extends Marionette.LayoutView
    template: 'admin/actions/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class ActionsList.ActionView extends Marionette.ItemView
    template: 'admin/actions/list/templates/action'
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
      ".js-value": 
        observe: "value"
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

  class ActionsList.ActionsTable extends Marionette.CompositeView
    template: 'admin/actions/list/templates/actions_table'
    childView: ActionsList.ActionView
    childViewContainer: "#actions-table tbody"