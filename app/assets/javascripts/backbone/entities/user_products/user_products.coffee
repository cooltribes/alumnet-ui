@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.UserProduct extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users/' + @get('user_id') + '/products'

  class Entities.UserProductsCollection extends Backbone.Collection
    model: Entities.UserProduct

  API =
    createUserProduct: (attrs)->
      user_product = new Entities.UserProduct(attrs)
      user_product.save attrs,
        error: (model, response, options) ->
          model.trigger('save:error', response, options)
        success: (model, response, options) ->
          model.trigger('save:success', response, options)
      user_product

    getUserProducts: (user_id)->
      products = new Entities.UserProductsCollection
      products.url = AlumNet.api_endpoint + '/users/' + user_id + '/products'
      products.fetch
        error: (collection, response, options)->
          collection.trigger('fetch:error')
        success: (collection, response, options) ->
          collection.trigger('fetch:success', collection)
      products

  AlumNet.reqres.setHandler 'user_product:create', (attrs) ->
    API.createUserProduct(attrs)