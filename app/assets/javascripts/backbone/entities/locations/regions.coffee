@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.Region extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/regions/'

  class Entities.Regions extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/regions'
    model: Entities.Region

  initializeRegions = ->
    Entities.regions = new Entities.Regions
    Entities.regions.fetch({async: false})

  API =
    getRegions: ()->
      initializeRegions() if Entities.regions == undefined
      Entities.regions

  AlumNet.reqres.setHandler 'get:regions', ->
    API.getRegions()

  class RegionList
    window.RegionList =
      toSelect2: ->
        regions = AlumNet.request 'get:regions'
        regions.map (model)->
          id: model.id
          text: model.get('name')
