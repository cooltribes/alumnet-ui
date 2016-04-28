@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Product extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/products/'

    validation:
      sku:
        required: true
        msg: "Product sku is required."
      name:
        required: true
        maxLength: 250
        msg: "Product name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Product description is required, must be less than 2048 characters"

  class Entities.ProductCollection extends Backbone.Collection
    model: Entities.Product

    url: ->
      AlumNet.api_endpoint + '/products'

  class Entities.UserProductsCollection extends Backbone.Collection
    model: Entities.Product

  initializeProducts = ->
    Entities.products = new Entities.ProductCollection

  API =
    getProductEntities: (querySearch)->
      products = new Entities.ProductCollection
      products.fetch
        data: querySearch
        success: (collection, response, options) ->
          products.trigger('fetch:success', collection)
      products

    getNewProduct: ->
      new Entities.Product

    findProduct: (id)->
      product = @findProductOnApi(id)

    findProductOnApi: (id)->
      product = new Entities.Product
        id: id
      product.fetch
        async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      product

  AlumNet.reqres.setHandler 'product:new', ->
    API.getNewProduct()

  AlumNet.reqres.setHandler 'product:entities', (querySearch) ->
    API.getProductEntities(querySearch)

  AlumNet.reqres.setHandler 'product:find', (id)->
    API.findProduct(id)