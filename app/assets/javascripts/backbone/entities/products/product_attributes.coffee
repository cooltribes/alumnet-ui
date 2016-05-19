@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.ProductAttribute extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/products/' + @get('product_id') + '/characteristics/'

  class Entities.ProductAttributeCollection extends Backbone.Collection
    model: Entities.ProductAttribute

    url: ->
      AlumNet.api_endpoint + '/products/characteristics'

  API =
    getProductAttributes: (querySearch)->
      product_attributes = new Entities.ProductAttributeCollection
      product_attributes.url = AlumNet.api_endpoint + '/products/' + querySearch.product_id + '/characteristics'
      product_attributes.fetch
        success: (collection, response, options) ->
          product_attributes.trigger('fetch:success', collection)
      product_attributes

    findProductAttribute: (product_id, attribute_id)->
      product_attribute = new Entities.ProductAttribute
        product_id: product_id
        attribute_id: parseInt(attribute_id)
      product_attribute.fetch
        async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      product_attribute

  AlumNet.reqres.setHandler 'product_attributes:entities', (querySearch) ->
    API.getProductAttributes(querySearch)

  AlumNet.reqres.setHandler 'product_attribute:find', (product_id, attribute_id)->
    API.findProductAttribute(product_id, attribute_id)