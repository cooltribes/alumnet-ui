@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Attribute extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/characteristics/'

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Attribute name is required, must be less than 250 characters long."

  class Entities.AttributeCollection extends Backbone.Collection
    model: Entities.Attribute

    url: ->
      AlumNet.api_endpoint + '/characteristics'

  API =
    getAttributes: (querySearch)->
      attributes = new Entities.AttributeCollection
      attributes.fetch
        data: querySearch
        success: (collection, response, options) ->
          attributes.trigger('fetch:success', collection)
      attributes

    findAttribute: (id)->
      attribute = @findAttributeOnApi(id)

    findAttributeOnApi: (id)->
      attribute = new Entities.Attribute
        id: id
      attribute.fetch
        async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      attribute

  AlumNet.reqres.setHandler 'attributes:entities', (querySearch) ->
    API.getAttributes(querySearch)

  AlumNet.reqres.setHandler 'attribute:find', (id)->
    API.findCategory(id)