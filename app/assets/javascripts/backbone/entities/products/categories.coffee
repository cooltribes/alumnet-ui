@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Category extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/categories/'

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Category name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Category description is required, must be less than 2048 characters"

  class Entities.CategoryCollection extends Backbone.Collection
    model: Entities.Category

    url: ->
      AlumNet.api_endpoint + '/categories'

  API =
    getCategories: (querySearch)->
      console.log 'query'
      console.log querySearch
      categories = new Entities.CategoryCollection
      categories.fetch
        data: querySearch
        success: (collection, response, options) ->
          console.log 'success'
          console.log collection
          categories.trigger('fetch:success', collection)
      categories

    findProduct: (id)->
      category = @findProductOnApi(id)

    findProductOnApi: (id)->
      category = new Entities.Category
        id: id
      category.fetch
        async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      category

    getCategoriesForSelect: ->
      categories = new Entities.CategoryCollection
      categories.fetch
        async: false
      categories.map (model)->
        id: model.id
        text: model.get('name')

  AlumNet.reqres.setHandler 'categories:entities', (querySearch) ->
    API.getCategories(querySearch)

  AlumNet.reqres.setHandler 'categories:entities:select', () ->
    API.getCategoriesForSelect()

  AlumNet.reqres.setHandler 'category:find', (id)->
    API.findCategory(id)