@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.Region extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/admin/regions/'

    countries: ->
      @get('countries')

    validation:
      name:
        required: true
        msg: 'Name of the Region is required'

  class Entities.Regions extends Backbone.Collection
    url: ->
      AlumNet.api_endpoint + '/admin/regions/'
    model: Entities.Region

  API =
    getRegions: ()->
      new Entities.Regions

    regionsToSelect2: ()->
      regions = new Entities.Regions
      regions.fetch
        async: false
      regions.map (model)->
        id: model.id
        text: model.get('name')


  AlumNet.reqres.setHandler 'get:regions', ->
    API.getRegions()

  AlumNet.reqres.setHandler 'get:regions:select2', ->
    API.regionsToSelect2()
