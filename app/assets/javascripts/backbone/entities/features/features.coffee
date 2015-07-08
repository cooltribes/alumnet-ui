@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Feature extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/features/'

    validation:
      name:
        required: true
        maxLength: 250
        msg: "Feature name is required, must be less than 250 characters long."
      description:
        required: true
        maxLength: 2048
        msg: "Feature description is required, must be less than 2048 characters"

  class Entities.FeatureCollection extends Backbone.Collection
    model: Entities.Feature

    url: ->
      AlumNet.api_endpoint + '/features'

  initializeFeatures = ->
    Entities.features = new Entities.FeatureCollection

  API =
    getFeatureEntities: (querySearch)->
      initializeFeatures() if Entities.features == undefined
      Entities.features.fetch
        data: querySearch
        success: (model, response, options) ->
          Entities.features.trigger('fetch:success')
      Entities.features

    getNewFeature: ->
      new Entities.Feature

    findFeature: (id)->
      feature = @findFeatureOnApi(id)

    findFeatureOnApi: (id)->
      feature = new Entities.Feature
        id: id
      feature.fetch
        # async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      feature

    findFeatureByKeyName: (key_name)->
      feature = @findFeatureOnApiByKeyName(key_name)

    findFeatureOnApiByKeyName: (key_name)->
      feature = new Entities.Feature
      feature.set("key_name", key_name)
      console.log 'inside function'
      console.log feature
      feature.fetch
        # async: false
        error: (model, response, options) ->
          model.trigger('find:error', response, options)
        success: (model, response, options) ->
          model.trigger('find:success')
      feature

  AlumNet.reqres.setHandler 'feature:new', ->
    API.getNewFeature()

  AlumNet.reqres.setHandler 'feature:entities', (querySearch) ->
    API.getFeatureEntities(querySearch)

  AlumNet.reqres.setHandler 'feature:find', (id)->
    API.findFeature(id)

  AlumNet.reqres.setHandler 'feature:findByKeyName', (key_name)->
    console.log 'key_name: '+key_name
    API.findFeatureByKeyName(key_name)