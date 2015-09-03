@AlumNet.module 'AdminApp.ProductsList', (ProductsList, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductsList.Layout extends Marionette.LayoutView
    template: 'admin/products/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class ProductsList.ProductView extends Marionette.ItemView
    template: 'admin/products/list/templates/product'
    tagName: "tr"

    modelEvents:
      "change": "modelChange"

    bindings:
      ".js-sku": 
        observe: "sku"
        events: ['blur']
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
      ".js-type": 
        observe: "product_type"
        selectOptions:
          collection: [
            value: 0
            label: "Time remaining"
          ,
            value: 1
            label: "Times used"
          ,
          ]
      ".js-quantity": 
        observe: "quantity"
        events: ['blur']
      ".js-feature": 
        observe: "feature"
        selectOptions:
          collection: [
            value: "subscription"
            label: "Subscription"
          ,
            value: "job_post"
            label: "Job Post"
          ,
          ]

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

  class ProductsList.ProductsTable extends Marionette.CompositeView
    template: 'admin/products/list/templates/products_table'
    childView: ProductsList.ProductView
    childViewContainer: "#products-table tbody"

  class ProductsList.ModalProduct extends Backbone.Modal
    template: 'admin/products/list/templates/modal_form'
    cancelEl: '#js-modal-close'

    initialize: (options)->
      @productTable = options.productTable

    templateHelpers: ->
      productIsNew: @model.isNew()

    events:
      'click #js-modal-save': 'saveClicked'
      'click #js-modal-delete': 'deleteClicked'

    saveClicked: (e)->
      e.preventDefault()
      modal = @
      model = @model
      table = @productTable
      data = Backbone.Syphon.serialize(modal)
      @model.save data,
        success: ->
          modal.destroy()
          model.trigger('render:view')
          if table
            table.collection.add(model)

    deleteClicked: (e)->
      e.preventDefault()
      modal = @
      resp = confirm('Are you sure?')
      if resp
        @model.destroy
          success: ->
            modal.destroy()