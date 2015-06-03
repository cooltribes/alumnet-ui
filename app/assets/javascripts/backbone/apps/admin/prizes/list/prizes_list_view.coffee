@AlumNet.module 'AdminApp.PrizesList', (PrizesList, @AlumNet, Backbone, Marionette, $, _) ->
  class PrizesList.Layout extends Marionette.LayoutView
    template: 'admin/prizes/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class PrizesList.PrizeView extends Marionette.ItemView
    template: 'admin/prizes/list/templates/prize'
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
      ".js-price": 
        observe: "price"
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

  class PrizesList.PrizesTable extends Marionette.CompositeView
    template: 'admin/prizes/list/templates/prizes_table'
    childView: PrizesList.PrizeView
    childViewContainer: "#prizes-table tbody"