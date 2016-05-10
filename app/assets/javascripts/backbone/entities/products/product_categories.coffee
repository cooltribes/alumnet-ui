@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.ProductCategory extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/products/' + @get('product_id') + '/categories/'

  class Entities.ProductCategoryCollection extends Backbone.Collection
    model: Entities.ProductCategory

    url: ->
      AlumNet.api_endpoint + '/products/categories'

  API =
    getProductCategories: (querySearch)->
      product_categories = new Entities.ProductCategoryCollection
      product_categories.url = AlumNet.api_endpoint + '/products/' + querySearch.product_id + '/categories'
      product_categories.fetch
        success: (collection, response, options) ->
          product_categories.trigger('fetch:success', collection)
      product_categories

    findProductCategory: (product_id, category_id)->
      product_category = new Entities.ProductCategory
        product_id: product_id
        category_id: parseInt(category_id)
      product_category.fetch
        async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      product_category

  AlumNet.reqres.setHandler 'product_categories:entities', (querySearch) ->
    API.getProductCategories(querySearch)

  AlumNet.reqres.setHandler 'product_category:find', (product_id, category_id)->
    API.findProductCategory(product_id, category_id)