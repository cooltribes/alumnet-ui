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

    events:
      'change #product-image': 'previewImage'

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
      # ".js-category": 
      #   observe: "category_id"
      #   selectOptions:
      #     collection: 'this.categories'

    initialize: (options) ->
      @productImage = options.model.get('image').image.card.url

    templateHelpers: ->
      model = @model
      productImage: @productImage
      category_name: ->
        if model.get('category')
          model.get('category').name
        else
          'No category'

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

    previewImage: (e)->
      $(e.currentTarget).siblings('div.loadingAnimation__migrateUsers').css('display','inline-block')
      $(e.currentTarget).siblings('.uploadF--blue').css('display','none')
      $(e.currentTarget).siblings('img').css('top',0)
      input = @.$('#product-image')
      preview = @.$('#prewiev-product-image')
      model = @model
      currentTarget= e.currentTarget

      formData = new FormData()
      file = @$('#product-image')
      formData.append('image', file[0].files[0])

      options_for_save =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: (model, response, options)->
          if input[0] && input[0].files[0]
           reader = new FileReader()
           reader.onload = (e)->
              preview.attr("src", e.target.result)
              $(currentTarget).siblings('div.loadingAnimation__migrateUsers').css('display','none')
              $(currentTarget).siblings('.uploadF--blue').css('display','inline-block')
              $(currentTarget).siblings('img').css('top',-30)
           reader.readAsDataURL(input[0].files[0])

      model.save(formData, options_for_save)

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